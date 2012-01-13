# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController  

  include Blacklight::Catalog
  # Extend Blacklight::Catalog with Hydra behaviors (primarily editing).
  include Hydra::Catalog

  # # These before_filters apply the hydra access controls
  before_filter :enforce_access_controls, :except=>[:update, :facet]
  # #before_filter :enforce_viewing_context_for_show_requests, :only=>:show
  before_filter :load_fedora_document, :only=>[:show, :edit]
  # # This applies appropriate access controls to all solr queries
  CatalogController.solr_search_params_logic << :add_access_controls_to_solr_params


	#Customised load_fedora_document to protect against users trying to access fileAsset objects
  def load_fedora_document
    af_base = ActiveFedora::Base.load_instance(params[:id])
    the_model = ActiveFedora::ContentModel.known_models_for( af_base ).first
    if the_model.nil?
      @document_fedora = af_base
    else
			#if it is a FileAsset object
		 	if the_model == FileAsset
				is_part_of_id = af_base.relationships(:is_part_of).first

				#if it has a part of relationship, redirect to the parent, otherwise redirect to index 
				if !is_part_of_id.nil? 
					is_part_of_id =  is_part_of_id[is_part_of_id.index('/')+1..-1]
					redirect_to :controller=>"catalog", :action=>"show", :id=> is_part_of_id
				else
					redirect_to :controller=>"catalog", :action=>"index"
				end
		  end
    end 

    @document_fedora = the_model.load_instance(params[:id])
		@file_assets = @document_fedora.file_objects(:response_format=>:solr)
   
  end

end 
