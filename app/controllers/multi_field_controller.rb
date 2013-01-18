class MultiFieldController < ApplicationController

  include MediaShelf::ActiveFedoraHelper
  include Hydra::AccessControlsEnforcement
  include HullAccessControlEnforcement

  before_filter :require_solr
  before_filter :enforce_access_controls, :only =>  [:create, :new, :update, :destroy]
  
  # Display form for adding a new field
  # If format is .inline, this renders without layout so you can embed it in a page

  def new
    @document_fedora = load_document_from_id(params[:asset_id])
    @datastream_name = params[:datastream_name]
    @fields = params[:fields]
    @field_label = params[:field_label]

    @next_field_index = eval '@document_fedora.datastreams[@datastream_name].find_by_terms(' + @fields + ').length'
    @content_type = params[:content_type]
    
    respond_to do |format|
      format.html { render :file=>"multi_field/new.html", :layout=>true}
      format.inline { render :partial=>"multi_field/new.html", :layout=>false }
    end
  end

  def create
    @document_fedora = load_document_from_id(params[:asset_id])
    datastream_name = params[:datastream_name]
    fields = params[:fields]

    multi_fields =  eval '@document_fedora.datastreams[datastream_name].find_by_terms(' + fields + ')'
    value = extract_value(params[:asset][datastream_name.to_sym])
    if multi_fields.length > 1 || (multi_fields.length == 1 && !multi_fields.first.inner_html.empty? )
      inserted_node, new_node_index = @document_fedora.insert_multi_field(datastream_name, fields)
      inserted_node.inner_html = value if value
    else
      eval '@document_fedora.datastreams[datastream_name].update_indexed_attributes({[' + fields + ']=>value})'  
    end
      
    @document_fedora.save

    respond_to do |format|
      format.html { redirect_to( edit_resource_path(params[:asset_id] ) ) }
      format.inline { render :partial=>partial_name, :locals=>{"edit_#{ct}".to_sym =>inserted_node, "edit_#{ct}_counter".to_sym =>new_node_index}, :layout=>false }
   end
    
  end

  def destroy
    fields = params[:fields]
    datastream_name = params[:datastream_name]
    @document_fedora = load_document_from_id(params[:asset_id]) 
    @document_fedora.remove_multi_field(datastream_name, fields, params[:index])
    result = @document_fedora.save
    respond_to do |format|
      format.html { redirect_to( edit_resource_path(params[:asset_id] ) ) }
      format.inline { render(:text=>result.inspect) }
    end
  end

  # TODO load_permissions_from_solr is duplicated in SubjectsController, ContributorsController, MultiFieldController & GrantNumbersController - Move to module
  # Over-ride the access_controls_enforcement method load_permissions_from_solr to use asset_id instead of 'id'
  def load_permissions_from_solr(id=params[:asset_id], extra_controller_params={})
    unless !@permissions_solr_document.nil? && !@permissions_solr_response.nil?
      @permissions_solr_response, @permissions_solr_document = get_permissions_solr_response_for_doc_id(id, extra_controller_params)
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

  # TODO enforce_new_permissions is duplicated in SubjectsController, ContributorsController, MultiFieldController & GrantNumbersController - Move to module
  ## proxies to enforce_edit_permssions. 
  def enforce_new_permissions(opts={})
    #Call the HullAccessControlsEnforcement method for checking create/new permissions
    enforce_create_permissions
  end
end
