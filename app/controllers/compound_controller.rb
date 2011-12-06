class CompoundController < ApplicationController

  include Hydra::AccessControlsEnforcement
  include Hydra::RepositoryController
  before_filter :enforce_edit_permissions, :except=>:show

  def show
    redirect_to resources_path(params[:id])
  end

  # Saves the uploaded file in a datastream of the object (instead of creating child assets like the FileAssetsController)
  def create
    @document_fedora = load_document_from_params
    if params.has_key?(:Filedata)
      file = params[:Filedata].first
      file_name = file.original_filename
      options = {:label=>file_name, :prefix=>'content'}
      ds_id = @document_fedora.add_file_datastream(file, options)

      size_attr = file.size
      pid = @document_fedora.pid
      @document_fedora.contentMetadata.insert_resource(:object_id => pid, :ds_id=>ds_id, :file_size=>size_attr, :url => datastream_content_url(:id=> pid,:datastream=>ds_id), :display_label=>@document_fedora.datastreams[ds_id].dsLabel)
      @document_fedora.save
      
      flash[:notice] = notice.join("<br/>".html_safe) unless notice.blank?
    else
      flash[:notice] = "You must specify a file to upload."
    end
    redirect_to edit_resource_path(@document_fedora)
  end

end
