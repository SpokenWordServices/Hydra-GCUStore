require 'mediashelf/active_fedora_helper'

class ContributorsController < ApplicationController
  include ContributorsHelper
  include MediaShelf::ActiveFedoraHelper
  before_filter :require_solr
  
  # Display form for adding a new Contributor
  # If contributor_type is provided, renders the appropriate "new" form
  # If contributor_type is not provided, renders a form for selecting which type of contributor to add
  # If format is .inline, this renders without layout so you can embed it in a page
  def new
    # Only load the document if you need to
    if params.has_key?(:contributor_type) 
      @document_fedora = load_document_from_id(params[:asset_id])
      @next_contributor_index = @document_fedora
    end
    
    respond_to do |format|
      format.html { render :file=>"contributors/new.html" , :layout=>true}
      format.inline { render :partial=>"contributors/new.html", :layout=>false }
    end
  end
  
  def create
    @document_fedora = load_document_from_id(params[:asset_id])
    
    ct = params[:contributor_type]
    inserted_node, new_node_index = @document_fedora.insert_contributor(ct)

    name  = extract_name_value(params[:asset][:descMetadata]) if params[:asset] && params[:asset].fetch(:descMetadata,nil)
    role = extract_role_value(params[:asset][:descMetadata]) if params[:asset] && params[:asset].fetch(:descMetadata,nil)

    inserted_node.at_css("namePart").inner_html = name if name
    inserted_node.at_css("roleTerm").inner_html = role if role

    @document_fedora.save
    partial_name = "contributors/edit_#{ct}.html"
    respond_to do |format|
      format.html { redirect_to( edit_resource_path(:id=>params[:asset_id] )+"##{params[:contributor_type]}_#{new_node_index}" ) }
      format.inline { render :partial=>partial_name, :locals=>{"edit_#{ct}".to_sym =>inserted_node, "edit_#{ct}_counter".to_sym =>new_node_index}, :layout=>false }
    end
    
  end
  
  def destroy
    @document_fedora = load_document_from_id(params[:asset_id])
    @document_fedora.remove_contributor(params[:contributor_type], params[:index])
    result = @document_fedora.save
    respond_to do |format|
      format.html { redirect_to( edit_resource_path(:id=>params[:asset_id] )) }
      format.inline { render(:text=>result.inspect) }
    end
  end
  
  private
  
  def load_document_from_id(asset_id)
    af_model = retrieve_af_model(params[:content_type], :default=>GenericContent)
    af_model.find(asset_id)
  end

end
