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

      options = {:label=>file_name, :prefix=>'content'}
      ds_id = @document_fedora.add_file_datastream(file, options)
			service_def =  ""
			service_method = ""
			

      size_attr = file.size
      pid = @document_fedora.pid
     
			#For the first content datastream add the following to contentMetadata... 
      if ds_id == "content"
				service_def =  Genre.find(@document_fedora.descMetadata.genre.first).c_model
				service_method = "getContent"
			else #For compound add...
				service_def =  "hydra-sDef:compoundContent"
				service_method = "getContent?dsID=" + ds_id
			end
		
      @document_fedora.contentMetadata.insert_resource(:object_id => pid, :ds_id=>ds_id, :file_size=>size_attr, :url => "http://hydra.hull.ac.uk/assets/" + pid + "/" + ds_id , :display_label=>@document_fedora.datastreams[ds_id].dsLabel, :id => @document_fedora.datastreams[ds_id].dsLabel,  :mime_type => mime_type, :format => mime_type[mime_type.index("/") + 1...mime_type.length], :service_def => service_def, :service_method => service_method)

			#Update the descMetadata for the primary content datastream
			if ds_id == "content"
	  	 update_hash = { "descMetadata"=> { [:physical_description,:extent]=> "Filesize: " + bits_to_human_readable(size_attr.to_i),
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
