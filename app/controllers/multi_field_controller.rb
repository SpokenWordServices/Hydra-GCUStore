require 'mediashelf/active_fedora_helper'
  
class MultiFieldController < ApplicationController

  include MediaShelf::ActiveFedoraHelper
  before_filter :require_solr, :require_fedora
  
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
    format.html { redirect_to( url_for(:controller=>"catalog", :action=>"edit", :id=>params[:asset_id] ) ) }
     format.inline { render :partial=>partial_name, :locals=>{"edit_#{ct}".to_sym =>inserted_node, "edit_#{ct}_counter".to_sym =>new_node_index}, :layout=>false }
   end
    
  end

  def destroy
	  af_model = retrieve_af_model(params[:content_type], :default=>HydrangeaArticle)
		fields = params[:fields]
		datastream_name = params[:datastream_name]
    @document_fedora = af_model.find(params[:asset_id])
    @document_fedora.remove_multi_field(datastream_name, fields, params[:index])
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
