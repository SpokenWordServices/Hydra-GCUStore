
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

  private

  def update_content_metadata
    logger.debug "updating container #{@container} with data for #{@file_asset}"

    #prefer the container_content_type param passed as local to the fluid_infusion/uploader partial
    afmodel = retrieve_af_model(params["container_content_type"])
    unless afmodel
      af_base = ActiveFedora::Base.load_instance(params[:id])
      afmodel = ActiveFedora::ContentModel.known_models_for( af_base ).first
    end
    if afmodel.nil?
      container = af_base
    else
      container = afmodel.load_instance(@container.pid)
    end
    container.insert_resource(:object_id => @file_asset.pid, :display_label=>get_default_display_label_for_content_type(params["container_content_type"])) if container.respond_to? :insert_resource
  end

  def get_default_display_label_for_content_type(content_type)
    case content_type
    when "uketd_object"
      return "Thesis"
    when "journal_article"
      return "Article"
    else
      return "Asset"
    end
  end

end
