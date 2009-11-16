require 'mediashelf/active_fedora_helper'
class DocumentsController < ApplicationController
    include MediaShelf::ActiveFedoraHelper
    include Blacklight::SolrHelper
    
    include Blacklight::CatalogHelper
    helper :salt, :metadata, :infusion_view
    
    before_filter :search_session, :history_session
    before_filter :require_solr, :require_fedora
    
    def edit
      @document = Document.find(params[:id])
      @response = get_solr_response_for_doc_id
      @document_solr = SolrDocument.new(@response.docs.first)
      respond_to do |format|
        format.html {setup_next_and_previous_documents}
      end
    end
    
    # Uses the update_indexed_attributes method provided by ActiveFedora::Base
    # This should behave pretty much like the ActiveRecord update_indexed_attributes method
    # For more information, see the ActiveFedora docs.
    # 
    # Examples
    # put :update, :id=>"_PID_", "document"=>{"subject"=>{"-1"=>"My Topic"}}
    # Appends a new "subject" value of "My Topic" to any appropriate datasreams in the _PID_ document.
    # put :update, :id=>"_PID_", "document"=>{"medium"=>{"1"=>"Paper Document", "2"=>"Image"}}
    # Sets the 1st and 2nd "medium" values on any appropriate datasreams in the _PID_ document, overwriting any existing values.
    def update
      @document = Document.find(params[:id])
      attrs = unescape_keys(params[:document])
      logger.debug("attributes submitted: #{attrs.inspect}")
      @document.update_indexed_attributes(attrs)
      @document.save
      response = attrs.keys.map{|x| escape_keys({x=>attrs[x].values})}
      logger.debug("returning #{response.inspect}")
      respond_to do |want| 
        want.js {
          render :json=> response.pop
        }
      end
    end
end