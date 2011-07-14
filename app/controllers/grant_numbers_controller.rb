require 'mediashelf/active_fedora_helper'

class GrantNumbersController < ApplicationController
  
  include MediaShelf::ActiveFedoraHelper
  before_filter :require_solr, :require_fedora
  
  # Display form for adding a new Grant Number
  # If format is .inline, this renders without layout so you can embed it in a page

  def new

    @document_fedora = load_document_from_id(params[:asset_id])
    @next_grant_number_index = @document_fedora
    @content_type = params[:content_type]
    
    respond_to do |format|
      format.html { render :file=>"grant_numbers/new.html", :layout=>true}
      format.inline { render :partial=>"grant_numbers/new.html", :layout=>false }
	  end
  end

  def create
debugger
    @document_fedora = load_document_from_id(params[:asset_id])
	
    inserted_node, new_node_index = @document_fedora.insert_grant_number()
#
#    value = extract_value(params[:asset][:descMetadata])
#    inserted_node.inner_html = value if value

    @document_fedora.save

    respond_to do |format|
      format.html { redirect_to( url_for(:controller=>"catalog", :action=>"edit", :id=>params[:asset_id] ) ) }
      format.inline { render :partial=>partial_name, :locals=>{"edit_#{ct}".to_sym =>inserted_node, "edit_#{ct}_counter".to_sym =>new_node_index}, :layout=>false }
    end
    
  end

  def destroy
    af_model = retrieve_af_model(params[:content_type], :default=>HydrangeaArticle)
    @document_fedora = af_model.find(params[:asset_id])
    @document_fedora.remove_grant_number(params[:index])
    result = @document_fedora.save
    respond_to do |format|
      format.html { redirect_to( url_for(:controller=>"catalog", :action=>"edit", :id=>params[:asset_id] ) ) }
      format.inline { render(:text=>result.inspect) }
    end
  end

  private
  
   def load_document_from_id(asset_id)

    af_model = retrieve_af_model(params[:content_type], :default=>HydrangeaArticle)
    af_model.find(asset_id)
  end
 
  def extract_value(hash)
    begin
      return hash.invert.keys.first.invert.keys.first
    rescue
      return nil
    end
  end
end
