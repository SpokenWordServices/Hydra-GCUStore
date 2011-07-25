require 'mediashelf/active_fedora_helper'

class AssetsController < ApplicationController
require_dependency 'vendor/plugins/hydra_repository/app/controllers/assets_controller'
		include HullAccessControlEnforcement
    include Hydra::AssetsControllerHelper

  before_filter :enforce_permissions, :only =>:new
  before_filter :load_document, :only => :update
  before_filter :update_set_membership, :only => :update
  before_filter :validate_parameters, :only =>[:create,:update]

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

      def load_document
        @document = load_document_from_params
      end

      def validate_parameters
        logger.debug("attributes submitted: #{@sanitized_params.inspect}")
        if @document.respond_to?(:valid_for_save?)
          if !@document.valid_for_save?(@sanitized_params)
            flash[:error] = "Encountered the following errors: #{@document.errors.join("; ")}"
            redirect_to :controller => "catalog", :action=>"edit"
          end
        end
        true
      end
		
			def update_set_membership
					if params["Structural Set"]
						structural_set_pid = params["Structural Set"].to_s.slice(params["Structural Set"].to_s.to_s.index('/')  + 1..params["Structural Set"].to_s.length) #remove info:fedora/ namespace from pid
						apply_set_membership(@document, structural_set_pid)
					end			
			end
end
