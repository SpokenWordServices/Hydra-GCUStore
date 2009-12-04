require 'mediashelf/active_fedora_helper'
class GetController < ApplicationController
    include MediaShelf::ActiveFedoraHelper
    include Stanford::SaltControllerHelper
    helper :downloads
    
    before_filter :require_fedora
    
    # Note: Actual downloads are handled by the index method insead of the show method
    # in order to avoid ActionController being clever with the filenames/extensions/formats.
    # To download a datastream, pass the datastream id as ?document_id=#{dsid} in the url
    def show
      fedora_object = ActiveFedora::Base.load_instance(params[:document_id])
      datastream = downloadables( fedora_object, :canonical=>true )
      send_data datastream.content, :filename=>datastream.label, :type=>datastream.attributes["mimeType"]
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