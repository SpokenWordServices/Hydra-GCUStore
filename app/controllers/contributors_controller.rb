require 'mediashelf/active_fedora_helper'
class ContributorsController < ApplicationController
  include MediaShelf::ActiveFedoraHelper
  before_filter :require_solr, :require_fedora
  def create
    af_model = retrieve_af_model(params[:content_type])
    unless af_model 
      af_model = HydrangeaArticle
    end
    @document = af_model.find(params[:asset_id])
    
    ct = params[:contributor_type]
    
    inserted_node, new_node_index = @document.insert_contributor(ct)
    
    partial_name = "hydrangea_articles/edit_#{ct}"
    render :partial=>partial_name, :locals=>{:edit_person=>inserted_node, :edit_person_counter=>new_node_index}, :layout=>false
  end
end