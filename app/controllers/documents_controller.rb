require 'mediashelf/active_fedora_helper'
class DocumentsController < ApplicationController
    include MediaShelf::ActiveFedoraHelper
    include Blacklight::SolrHelper
    
    include Blacklight::CatalogHelper
    helper :salt, :metadata
    
    before_filter :search_session, :history_session
    before_filter :require_solr, :require_fedora
    
    def edit
      @document = Document.find(params[:id])
      respond_to do |format|
        format.html {setup_next_and_previous_documents}
      end
    end
    
    def update
      @document = Document.find(params[:id])
      attrs = unescape_keys(params[:basic_asset])
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