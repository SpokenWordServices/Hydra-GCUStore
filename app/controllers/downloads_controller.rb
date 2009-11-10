require 'mediashelf/active_fedora_helper'
class DownloadsController < ApplicationController
    include MediaShelf::ActiveFedoraHelper
    helper :downloads
    
    before_filter :require_fedora
    
    def index
      @fedora_object = ActiveFedora::Base.load_instance(params[:document_id])
      @datastreams = @fedora_object.datastreams
      
      if params[:download_id]
        @datastream = @datastreams[params[:download_id]]
        send_data @datastream.content, :filename=>@datastream.label, :type=>@datastream.attributes["mimeType"]
        #send_data( Fedora::Repository.instance.fetch_custom(params[:document_id], "datastreams/#{datastream_id}/content") )
      end
    end
    
    # def show
    #   puts "params: #{params.inspect}"
    #   puts "Request: #{request.inspect}"
    #   puts "Path: #{request.path}"
    #   
    #   datastream_id = File.basename(request.path)
    #   respond_to do |format|
    #     format.html { send_data( Fedora::Repository.instance.fetch_custom(params[:document_id], "datastreams/#{datastream_id}/content") ) }
    #     format.pdf { send_data( Fedora::Repository.instance.fetch_custom(params[:document_id], "datastreams/#{datastream_id}/content") ) }
    #   end
    #   
    # end

end