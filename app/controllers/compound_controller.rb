require 'rvideo'


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
			mime_type = file.content_type

      options = {:label=>file_name, :prefix=>'content', :checksumType => 'MD5'}
      ds_id = @document_fedora.add_file_datastream(file, options)
			service_def =  ""
			service_method = ""
			

      size_attr = file.size
      pid = @document_fedora.pid


      #Attempt to get dimesions of video if appropriate
      height=""
      width=""
      duration=""
      if mime_type.include?('video') || mime_type.include?('audio')
         vid_file= RVideo::Inspector.new(:file => file.path)
         if vid_file.unreadable_file?
              logger.warn 'ffmpeg can\'t read the uploaded file'
         else 
             if mime_type.include?('video')
               height=vid_file.height
               width=vid_file.width
             end
             duration=vid_file.raw_duration              
         end
      end 
        
     
			#For the first content datastream add the following to contentMetadata... 
      if ds_id == "content"
				service_def =  Genre.find(@document_fedora.descMetadata.genre.first).c_model
				service_method = "getContent"
			else #For compound add...
				service_def =  "hydra-sDef:compoundContent"
				service_method = "getContent?dsID=" + ds_id
			end
		
      @document_fedora.contentMetadata.insert_resource(:object_id => pid, :ds_id=>ds_id, :file_size=>size_attr, :url => "http://hydra.hull.ac.uk/assets/" + pid + "/" + ds_id , :display_label=>@document_fedora.datastreams[ds_id].dsLabel, :id => @document_fedora.datastreams[ds_id].dsLabel,  :mime_type => mime_type, :format => mime_type[mime_type.index("/") + 1...mime_type.length], :service_def => service_def, :service_method => service_method, :height=> height, :width=> width)

			#Update the descMetadata for the primary content datastream
      # remove addition of filesize in extent as we suse this to store duration of a/v files and anyway don't think it's appropriate.  
      # [:physical_description,:extent]=> "Filesize: " + bits_to_human_readable(size_attr.to_i),
			if ds_id == "content"
	  	 update_hash = { "descMetadata"=> { 
                    [:physical_description,:extent]=> duration,
										[:physical_description,:mime_type]=>mime_type,
							       [:location,:raw_object]=> "http://hydra.hull.ac.uk/assets/" + pid + "/content" }
				}
				@document_fedora.update_datastream_attributes( update_hash )
			end
				
      @document_fedora.save
      
      flash[:notice] = notice.join("<br/>".html_safe) unless notice.blank?



    else
      flash[:notice] = "You must specify a file to upload."
    end
    redirect_to edit_resource_path(@document_fedora)
  end

  # Delete the appropriate datastream and update the content metadata
  def destroy

    @document_fedora = load_document_from_params
    #get datastreamID and delete
    ds_id = @document_fedora.get_values_from_datastream("contentMetadata",[{:resource=>params[:index]}, :resource_ds_id])[0]
    file_id = @document_fedora.get_values_from_datastream("contentMetadata",[{:resource=>params[:index]}, :file, :file_id])[0]
    @document_fedora.datastreams[ds_id].delete
    
    #remove contentMetadata
    @document_fedora.contentMetadata.remove_resource(params[:index])
    @document_fedora.contentMetadata.serialize!
    @document_fedora.save

    
    flash[:notice] = "Deleted #{ds_id}: #{file_id}."
    redirect_to edit_resource_path(@document_fedora)
 

  end
 
 private
  		# Returns a human readable filesize appropriate for the given number of bytes (ie. automatically chooses 'bytes','KB','MB','GB','TB')
      # Based on a bit of python code posted here: http://blogmag.net/blog/read/38/Print_human_readable_file_size
      # @param [Numeric] file size in bits
      def bits_to_human_readable(num)
          ['bytes','KB','MB','GB','TB'].each do |x|
            if num < 1024.0
              return "#{num.to_i} #{x}"
            else
              num = num/1024.0
            end
          end
      end



end
