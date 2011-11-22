class FileAssetsController < ApplicationController
  include Hydra::FileAssets

  after_filter :update_metadata, :only => [:create]
  after_filter :destroy_metadata, :only => [:destroy]

  def datastream
    if params[:datastream] 
      af_base = ActiveFedora::Base.load_instance(params[:id])
      the_model = ActiveFedora::ContentModel.known_models_for( af_base ).first
      @object = the_model.load_instance(params[:id])
      if @object && @object.datastreams.keys.include?(params[:datastream])
        render :xml => @object.datastreams[params[:datastream]].content
        return
      end
    end
    render :text => "Unable to load datastream"
  end

  private
  def update_metadata
    return if @file_assets.nil?
    @file_asset = @file_assets.first
    container = find_container
    update_content_metadata(container)
    update_desc_metadata(container)
  end

  def destroy_metadata
      container = find_container
      container.remove_resource(params[:index])
      container.contentMetadata.serialize!
      container.save
  end

  def find_container
    #prefer the container_content_type param passed as local to the fluid_infusion/uploader partial
    afmodel = retrieve_af_model(params["container_content_type"])
    unless afmodel
      af_base = ActiveFedora::Base.load_instance(params[:container_id])
      afmodel = ActiveFedora::ContentModel.known_models_for( af_base ).first
    end
    if afmodel.nil?
      container = af_base
    else
      container = afmodel.load_instance(params[:container_id])
    end
    container
  end

  def update_content_metadata(container)
    size_attr = @file_asset.datastreams["content"].size
    node, index = container.insert_resource(:object_id => @file_asset.pid, :ds_id=>"content", :file_size=>size_attr, :url => datastream_content_url(:id=>@file_asset.pid,:datastream=>"content"), :display_label=>get_default_display_label_for_content_type(params["container_content_type"])) if container.respond_to? :insert_resource
    container.datastreams["contentMetadata"].serialize!
    container.datastreams["contentMetadata"].save
  end

  def update_desc_metadata(container)
    update_hash = {
      [:physical_description,:extent]=>@file_asset.datastreams["content"].size,
      [:physical_description,:mime_type]=>@file_asset.datastreams["content"].mimeType,
      [:location,:raw_object]=>datastream_content_path(:id=>@file_asset.pid,:datastream=>"content")
    }
    container.datastreams["descMetadata"].update_values(update_hash)
    container.datastreams["descMetadata"].save
  end
  
# Returns:
  def get_default_display_label_for_content_type(content_type)
    display_label =@file_asset.label
    if !display_label
      display_label =
        case content_type
        when "uketd_object"
          return "Thesis"
        when "journal_article"
          return "Article"
        else
          return "Asset"
        end
    end
    display_label
  end


  ### override from hydrahead, this ensures the content of the file upload will be saved in a datastream named "content"
  def datastream_id
    'content'
  end

end
