require 'mediashelf/active_fedora_helper'

class GrantssController < ApplicationController
  include MediaShelf::ActiveFedoraHelper
  before_filter :require_solr, :require_fedora
  
  def new
    render :partial=>"grants/new"
  end
  
  def create
    af_model = retrieve_af_model(params[:content_type], :default=>HydrangeaArticle)
    @document_fedora = af_model.find(params[:asset_id])
    
    ct = params[:grant_type]
    inserted_node, new_node_index = @document_fedora.insert_grant(ct)
    @document_fedora.save
    partial_name = "grants/edit"
    render :partial=>partial_name, :layout=>false
  end
  
  def destroy
    af_model = retrieve_af_model(params[:content_type], :default=>HydrangeaArticle)
    @document_fedora = af_model.find(params[:asset_id])
    @document_fedora.remove_grant(params[:grant_type], params[:index])
    result = @document_fedora.save
    render :text=>result.inspect
  end
  
end