require 'mediashelf/active_fedora_helper'
  
class GrantNumbersController < ApplicationController

  include MediaShelf::ActiveFedoraHelper
  before_filter :require_solr
  
  # Display form for adding a new Grant Number
  # If format is .inline, this renders without layout so you can embed it in a page

  def new
    @document_fedora = load_document_from_id(params[:asset_id])
    
    @next_grant_number_index = @document_fedora.datastreams["descMetadata"].find_by_terms(:grant_number).length

    @content_type = params[:content_type]
    
    respond_to do |format|
      format.html { render :file=>"grant_numbers/new.html", :layout=>true}
      format.inline { render :partial=>"grant_numbers/new.html", :layout=>false }
	  end
  end

  def create
    @document_fedora = load_document_from_id(params[:asset_id])

    grant_numbers = @document_fedora.datastreams["descMetadata"].find_by_terms(:grant_number)
    value = extract_value(params[:asset][:descMetadata])
    if grant_numbers.length > 1 || (grant_numbers.length == 1 && !grant_numbers.first.inner_html.empty? )
      inserted_node, new_node_index = @document_fedora.insert_grant_number()
      inserted_node.inner_html = value if value
    else
      @document_fedora.datastreams["descMetadata"].update_indexed_attributes({[{:grant_number =>"0"}]=>value})
    end
      
    @document_fedora.save

    respond_to do |format|
      format.html { redirect_to( edit_resource_path(params[:asset_id]))}
      format.inline { render :partial=>partial_name, :locals=>{"edit_#{ct}".to_sym =>inserted_node, "edit_#{ct}_counter".to_sym =>new_node_index}, :layout=>false }
    end
    
  end

  def destroy
    af_model = retrieve_af_model(params[:content_type], :default=>GenericContent)
    @document_fedora = af_model.find(params[:asset_id])
    @document_fedora.remove_grant_number(params[:index])
    result = @document_fedora.save
    respond_to do |format|
      format.html { redirect_to( edit_resource_path(params[:asset_id]))}
      format.inline { render(:text=>result.inspect) }
    end
  end

  private
  
   def load_document_from_id(asset_id)
    af_model = retrieve_af_model(params[:content_type], :default=>GenericContent)
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