#require 'mediashelf/active_fedora_helper'
require 'digest/md5'
require 'uri'

class DownloadsController < ApplicationController
    include Hydra::RepositoryController
    include Hydra::AccessControlsEnforcement
    helper :downloads
    
    #Enforces permissions on the downloads by using enforce_show_permissions method
    before_filter :enforce_show_permissions, :only =>  [:index, :serve]
    
    # Note: Actual downloads are handled by the index method insead of the show method
    # in order to avoid ActionController being clever with the filenames/extensions/formats.
    # To download a datastream, pass the datastream id as ?document_id=#{dsid} in the url
    def index
      fedora_object = ActiveFedora::Base.load_instance(params[:id])
      if params[:download_id]
        @datastream = fedora_object.datastreams[params[:download_id]]
        send_data @datastream.content, :filename=>filename_from_datastream_name_and_mime_type(fedora_object.pid, params[:download_id], @datastream.mimeType), :type=>@datastream.mimeType
      else
        @datastreams = downloadables( fedora_object )
      end
    end

    # serve up datastream content direct fromt the file-system.  Useful for audio/video or large files.

    def serve    
      fedora_object = ActiveFedora::Base.load_instance(params[:id])
      @datastream = fedora_object.datastreams[params[:datastream_id]]
      if @datastream.nil?
        return redirect_to resources_url, :notice => "This content does not exist" 
      end
      if @datastream.controlGroup == "M"
        datastream_file=datastream_file_location(params[:id],params[:datastream_id], @datastream.dsVersionID)
        send_file datastream_file, :type => @datastream.mimeType, :disposition => 'inline'
      else
        redirect_to resources_url, :notice => "This content cannot be served directly. Try using #{download_datastream_content_url :id=>params[:id], :download_id=>params[:datastream_id]}" 
      end
    end

    
    private

    def filename_from_datastream_name_and_mime_type(pid, datastream_name, mime_type)
      # if mime type exists, grab the first extension listed for the first returned mime type
      extension = MIME::Types[mime_type].length > 0 ? ".#{MIME::Types[mime_type].first.extensions.first}" : ""
      "#{datastream_name}-#{pid.gsub(/:/,'_')}#{extension}"
    end

    #Determine file location based on akubra default filepath alogorithm
    def datastream_file_location(pid,datastream_id,datastream_version)
        uri="info:fedora/#{pid}/#{datastream_id}/#{datastream_version}"
        digest= Digest::MD5.hexdigest(uri) 
        filename=URI.escape(uri, ":/")
        return GCU_CONFIG[:fedora_datastream_store]+digest[0,2]+'/'+filename
    end 
end
