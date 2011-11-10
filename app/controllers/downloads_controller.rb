require 'mediashelf/active_fedora_helper'
class DownloadsController < ApplicationController
    include Hydra::RepositoryController
    helper :downloads
    
    
    # Note: Actual downloads are handled by the index method insead of the show method
    # in order to avoid ActionController being clever with the filenames/extensions/formats.
    # To download a datastream, pass the datastream id as ?document_id=#{dsid} in the url
    def index
      fedora_object = ActiveFedora::Base.load_instance(params[:asset_id])
      if params[:download_id]
        @datastream = fedora_object.datastreams[params[:download_id]]
        send_data @datastream.content, :filename=>filename_from_datastream_name_and_mime_type(fedora_object.pid, params[:download_id], @datastream.mimeType), :type=>@datastream.mimeType
      else
        @datastreams = downloadables( fedora_object )
      end
    end
    
    private

    def filename_from_datastream_name_and_mime_type(pid, datastream_name, mime_type)
      # if mime type exists, grab the first extension listed for the first returned mime type
      extension = MIME::Types[mime_type].length > 0 ? ".#{MIME::Types[mime_type].first.extensions.first}" : ""
      "#{datastream_name}-#{pid.gsub(/:/,'_')}#{extension}"
    end
    
end
