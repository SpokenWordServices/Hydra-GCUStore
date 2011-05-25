require 'mediashelf/active_fedora_helper'
class DownloadsController < ApplicationController
    include MediaShelf::ActiveFedoraHelper
    include Hydra::RepositoryController
    helper :downloads
    
    before_filter :require_fedora
    
    # Note: Actual downloads are handled by the index method insead of the show method
    # in order to avoid ActionController being clever with the filenames/extensions/formats.
    # To download a datastream, pass the datastream id as ?document_id=#{dsid} in the url
    def index
      fedora_object = ActiveFedora::Base.load_instance(params[:asset_id])
      if params[:download_id]
         
        @datastream = fedora_object.datastreams[params[:download_id]]
        send_data @datastream.content, :filename=>filename_from_datastream_name_and_mime_type(params[:download_id], @datastream.attributes["mimeType"]), :type=>@datastream.attributes["mimeType"]
        #send_data( Fedora::Repository.instance.fetch_custom(params[:document_id], "datastreams/#{datastream_id}/content") )
      else
        @datastreams = downloadables( fedora_object )
      end
    end
    
    private

    def filename_from_datastream_name_and_mime_type(datastream_name, mime_type)
      # if mime type exists, grab the first extension listed for the first returned mime type
      extension = MIME::Types[mime_type].length > 0 ? ".#{MIME::Types[mime_type].first.extensions.first}" : ""
      "#{datastream_name}#{extension}"
    end
    
end
