
class FileAssetsController < ApplicationController

  require_dependency 'vendor/plugins/hydra_repository/app/controllers/file_assets_controller.rb'
  
  after_filter :update_content_metadata, :only => [:create,:destroy]

  # NOTE: overwriting this method to handle redirection back to edit view of container
  def create
    @file_asset = create_and_save_file_asset_from_params
    apply_depositor_metadata(@file_asset)
        
    if !params[:container_id].nil?
      @container =  ActiveFedora::Base.load_instance(params[:container_id])
      @container.file_objects_append(@file_asset)
      @container.save
    end
    
    ## FOR CAPTURING ANY FILE METADATA // THERE'S PROBABY A BETTER PLACE FOR THIS. 
    unless params[:asset].nil?
      updater_method_args = prep_updater_method_args(params)
      logger.debug("attributes submitted: #{updater_method_args.inspect}")
      result = @file_asset.update_indexed_attributes(updater_method_args[:params], updater_method_args[:opts])
      @file_asset.save
    end
    ##
    
    logger.debug "Created #{@file_asset.pid}."
    respond_to do |format|
      if @container
        format.html { redirect_to( edit_catalog_path(@container.pid) ) }
      else
        format.html { render :nothing => true }
      end
      format.inline { render :nothing => true }
    end
  end

  # Common destroy method for all AssetsControllers 
  def destroy
    # The correct implementation, with garbage collection:
    # if params.has_key?(:container_id)
    #   container = ActiveFedora::Base.load_instance(params[:container_id]) 
    #   container.file_objects_remove(params[:id])
    #   FileAsset.garbage_collect(params[:id])
    # else
    
    # The dirty implementation (leaves relationship in container object, deletes regardless of whether the file object has other containers)
    ActiveFedora::Base.load_instance(params[:id]).delete 
    respond_to do |format|
      if params[:container_id]
        format.html { redirect_to( edit_catalog_path(params[:container_id]) ) }
      else
        format.html { render :text => "Deleted #{params[:id]} from #{params[:container_id]}." }
      end
    end
  end
  private

  def update_content_metadata
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
      node, index = container.insert_resource(:object_id => @file_asset.pid, :display_label=>get_default_display_label_for_content_type(params["container_content_type"])) if container.respond_to? :insert_resource
      container.datastreams["contentMetadata"].save
      container.save
    elsif params[:action]=="destroy"
      # add logic to get the appropriate index
      container.remove_resource(params[:index])
      container.save
    end
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
