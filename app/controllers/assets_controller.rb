require 'mediashelf/active_fedora_helper'

class AssetsController < ApplicationController
		include HullAccessControlEnforcement
    include Hydra::AssetsControllerHelper

		before_filter :enforce_permissions, :only =>:new

 	def new
      af_model = retrieve_af_model(params[:content_type])
      if af_model
        @asset = af_model.new
				apply_base_metadata(@asset)
        apply_depositor_metadata(@asset)
        set_collection_type(@asset, params[:content_type])
        @asset.save
      end
      redirect_to url_for(:action=>"edit", :controller=>"catalog", :id=>@asset.pid)
    end 

	 # Uses the update_indexed_attributes method provided by ActiveFedora::Base
    # This should behave pretty much like the ActiveRecord update_indexed_attributes method
    # For more information, see the ActiveFedora docs.
    # 
    # @example Appends a new "subject" value of "My Topic" to on the descMetadata datastream in in the _PID_ document.
    #   put :update, :id=>"_PID_", "asset"=>{"descMetadata"=>{"subject"=>{"-1"=>"My Topic"}}
    # @example Sets the 1st and 2nd "medium" values on the descMetadata datastream in the _PID_ document, overwriting any existing values.
    #   put :update, :id=>"_PID_", "asset"=>{"descMetadata"=>{"medium"=>{"0"=>"Paper Document", "1"=>"Image"}}
    def update
      @document = load_document_from_params
      
      logger.debug("attributes submitted: #{@sanitized_params.inspect}")
         
      @response = update_document(@document, @sanitized_params)
			apply_additional_metadata(@document)       

      @document.save
      flash[:notice] = "Your changes have been saved."
      
      logger.debug("returning #{response.inspect}")
    
      respond_to do |want| 
        want.html {
          redirect_to :controller=>"catalog", :action=>"edit"
        }
        want.js {
          render :json=> tidy_response_from_update(@response)  
        }
        want.textile {
          if @response.kind_of?(Hash)
            textile_response = tidy_response_from_update(@response).values.first
          end
          render :text=> white_list( RedCloth.new(textile_response, [:sanitize_html]).to_html )
        }
      end
    end

		protected
			def enforce_permissions
				enforce_create_permissions
			end
end
