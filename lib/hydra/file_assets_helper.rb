
module Hydra::FileAssetsHelper
  require_dependency 'vendor/plugins/hydra_repository/lib/hydra/file_assets_helper.rb'
  
  # Creates a File Asset and sets its label from params[:Filename]
  #
  # @return [FileAsset] the File Asset
  def create_asset_from_params
    if params[:container_id] && pid = next_asset_pid(params[:container_id])
      file_asset = FileAsset.new(:pid=>pid)
    else
      file_asset = FileAsset.new
    end
    file_asset.label = params[:Filename]

    return file_asset
  end
 
  # Calculates the next available child asset pid (based on pid+alpha sequence)
  #
  # @param [String] container_id pid of the parent object
  # @return [String] the next available pid
  #
  # @example:  next_asset_pid("hull:3108") => "hull:3108a" if no child asset previously existed
  def next_asset_pid(container_id)
    # build the query hashes for checking existing records in solr
    # the child FileAssets have active_fedora_model_s = ActiveFedora::Base
    # and have a has_model_s assertion = "info:fedora/afmodel:FileAsset
    # and an is_part_of_s assertion pointing back to the container
    field_hash = {"is_part_of_s" => "info:fedora/#{container_id}"}
    options = {:field_list => ["id"],:rows=>30}

    # query solr for existing child assets
    # NOTE: querying twice at the moment because existing children are ActiveFedora::Base
    #       whereas newly created objects will be FileAsset objects
    # TODO: make a decision about underlying model to use when creating these assets
    resp = ActiveFedora::Base.find_by_fields_by_solr(field_hash, options)
    af_id_array = resp.hits.map {|h| h["id"] }
    resp = FileAsset.find_by_fields_by_solr(field_hash, options)
    fa_id_array = resp.hits.map {|h| h["id"] }.sort
    id_array = (af_id_array + fa_id_array).sort
    logger.debug("existing siblings - #{id_array}")
    if id_array.empty? 
      return "#{container_id}a" 
    else
      if id_array[-1].match /[a-zA-Z]$/ 
        return "#{container_id}#{id_array[-1].split('')[-1].succ}"
      else
        return nil
      end
    end

  end

  # Puts the contents of params[:Filedata] (posted blob) into a datastream within the given @asset
  #
  # @param [FileAsset] the File Asset to add the blob to
  # @return [FileAsset] the File Asset  
  # @note This is overwriting the default which assumes params[:Filename]
  def add_posted_blob_to_asset(asset=@file_asset)
    file_name = params[:Filename] ? params[:Filename] : params[:Filedata].original_filename
    asset.add_file_datastream(params[:Filedata],:dsid=>"content", :label=>file_name, :mimeType=>mime_type(file_name))
  end

end
