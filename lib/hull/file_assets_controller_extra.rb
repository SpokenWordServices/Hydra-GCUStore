module FileAssetsControllerExtra
  extend ActiveSupport::Concern
  
  included do
    after_filter :update_metadata, :only => [:create,:destroy]
  end

  module InstanceMethods
    private
    def update_metadata
      logger.debug "updating container #{@container} with data for #{@file_asset}"
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
      if params[:action] == "create"
        update_content_metadata(container)
        update_desc_metadata(container)
      elsif params[:action]=="destroy"
        delete_content_metadata(container)
        container.save
      end
    end

    def update_content_metadata(container)
      size_attr = @file_asset.datastreams["content"].size
      node, index = container.insert_resource(:object_id => @file_asset.pid,:file_size=>size_attr, :url => datastream_content_url(:id=>@file_asset.pid,:datastream=>"content"), :display_label=>get_default_display_label_for_content_type(params["container_content_type"])) if container.respond_to? :insert_resource
      container.datastreams["contentMetadata"].save
    end

    def delete_content_metadata(container)
      container.remove_resource(params[:index])
    end

    def update_desc_metadata(container)
      update_hash = {
        [:physical_description,:extent]=>@file_asset.datastreams["content"].size,
        [:physical_description,:mime_type]=>@file_asset.datastreams["content"].mime_type,
        [:location,:raw_object]=>datastream_content_path(:id=>@file_asset.pid,:datastream=>"content")
      }
      container.datastreams["descMetadata"].update_values(update_hash)
      container.datastreams["descMetadata"].save
    end
    
  # Returns:
    def get_default_display_label_for_content_type(content_type)
      display_label = params[:Filedata].original_filename
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
  end

end
