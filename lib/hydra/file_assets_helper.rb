module Hydra::FileAssetsHelper
  
  #require_dependency 'vendor/plugins/hydra_repository/lib/hydra/file_assets_helper.rb'
  # Creates a File Asset, adding the posted blob to the File Asset's datastreams and saves the File Asset
  #
  # @return [FileAsset] the File Asset  
  def create_and_save_file_assets_from_params
    if params.has_key?(:Filedata)
      @file_assets = []
      params[:Filedata].each do |file|
        @file_asset = create_asset_from_file(file)
        add_posted_blob_to_asset(@file_asset,file)
        @file_asset.save
        @file_assets << @file_asset
      end
      return @file_assets
    else
      render :text => "400 Bad Request", :status => 400
    end
  end
  
  # Puts the contents of params[:Filedata] (posted blob) into a datastream within the given @asset
  # Sets asset label and title to filename if they're empty
  #
  # @param [FileAsset] the File Asset to add the blob to
  # @return [FileAsset] the File Asset  
  def add_posted_blob_to_asset(asset,file)
    #file_name = filename_from_params
    file_name = file.original_filename
    options = {:label=>file_name, :mimeType=>mime_type(file_name), :checksumType => 'MD5'} #MD5 checksums added
    dsid = datastream_id #Only call this once so that it could be a sequence
    options[:dsid] = dsid if dsid
    asset.add_file_datastream(file, options)
    asset.set_title_and_label( file_name, :only_if_blank=>true )
  end

  #Override this if you want to specify the datastream_id (dsID) for the created blob
  def datastream_id
    "content"
  end
  
  # Associate the new file asset with its container
  def associate_file_asset_with_container(file_asset=nil, container_id=nil)
    if container_id.nil?
      container_id = params[:asset_id]
    end
    if file_asset.nil?
      file_asset = @file_asset
    end
		file_asset.add_relationship(:is_part_of, container_id)
    file_asset.datastreams["RELS-EXT"].dirty = true
    file_asset.save
  end
  
  # Apply any posted file metadata to the file asset
  def apply_posted_file_metadata         
    @metadata_update_response = update_document(@file_asset, @sanitized_params)
    @file_asset.save
  end
  
  
  # The posted File 
  # @return [File] the posted file.  Defaults to nil if no file was posted.
  def posted_file
    params[:Filedata]
  end
  
  # A best-guess filename based on POST params
  # If Filename was submitted, it uses that.  Otherwise, it calls +original_filename+ on the posted file
  def filename_from_params
    if !params[:Filename].nil?
      file_name = params[:Filename]      
    else
      file_name = posted_file.original_filename
      params[:Filename] = file_name
    end
  end
  
  # Creates a File Asset and sets its label from params[:Filename]
  #
  # @return [FileAsset] the File Asset
  def create_asset_from_params    
    file_asset = FileAsset.new
    file_asset.label = params[:Filename]
    
    return file_asset
  end
  
  # Creates a File Asset and sets its label from filename
  #
  # @return [FileAsset] the File Asset
  def create_asset_from_file(file)
		#Added functionality to create child_objects with parentPID + 'a/b/c..'
		if params[:container_id] && pid = next_asset_pid(params[:container_id])
      file_asset = FileAsset.new(:pid=>pid)
    else
    	file_asset = FileAsset.new
		end    
		file_asset.label = file.original_filename

    return file_asset
  end
  
  # This is pre-Hydra code that created an AudioAsset, VideoAsset or ImageAsset based on the
  # current params in the controller.
  #
  # @return [Constant] the recommended Asset class
  def asset_class_from_params
    if params.has_key?(:type)
      chosen_type = case params[:type]
      when "AudioAsset"
        AudioAsset
      when "VideoAsset"
        VideoAsset
      when "ImageAsset"
        ImageAsset
      else
        FileAsset
      end
    elsif params.has_key?(:Filename)
      chosen_type = choose_model_by_filename( params[:Filename] )
    else
      chosen_type = FileAsset
    end
    
    return chosen_type
  end
  
  def choose_model_by_filename(filename)
    choose_model_by_filename_extension( File.extname(filename) )
  end
  
  # Rudimentary method to choose an Asset class based on a filename extension
  #
  # @param [String] extension
  # @return [Constant] the recommended Asset class.  Default: FileAsset
  #
  # Recognized extensions: 
  # AudioAsset => ".wav", ".mp3", ".aiff"
  # VideoAsset => ".mov", ".flv", ".mp4"
  # ImageAsset => ".jpeg", ".jpg", ".gif", ".png"
  def choose_model_by_filename_extension(extension)
    
    Hydra.config[:file_asset_types][:extension_mappings].each_pair do |klass, extensions|
      if extensions.include?(extension)
        return klass
      end
    end
    
    return Hydra.config[:file_asset_types][:default]
    
    # case extension
    # when ".wav", ".mp3", ".aiff"
    #   AudioAsset
    # when ".mov", ".flv", ".mp4", ".m4v"
    #   VideoAsset
    # when ".jpeg", ".jpg", ".gif", ".png"
    #   ImageAsset
    # else
    #  FileAsset
    # end
  end

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
  #def add_posted_blob_to_asset(asset=@file_asset)
  #  file_name = params[:Filename] ? params[:Filename] : params[:Filedata].original_filename
  #  asset.add_file_datastream(params[:Filedata],:dsid=>"content", :label=>file_name, :mimeType=>mime_type(file_name))
  #end

  private
  # Return the mimeType for a given file name
  # @param [String] file_name The filename to use to get the mimeType
  # @return [String] mimeType for filename passed in. Default: application/octet-stream if mimeType cannot be determined
  def mime_type file_name
    mime_types = MIME::Types.of(file_name)
    mime_type = mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type
  end


end
