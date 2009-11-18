require 'mediashelf/active_fedora_helper'
class DownloadsController < ApplicationController
    include MediaShelf::ActiveFedoraHelper
    helper :downloads
    
    before_filter :require_fedora
    
    # Note: Actual downloads are handled by the index method insead of the show method
    # in order to avoid ActionController being clever with the filenames/extensions/formats.
    # To download a datastream, pass the datastream id as ?document_id=#{dsid} in the url
    def index
      fedora_object = ActiveFedora::Base.load_instance(params[:document_id])
      if params[:download_id]
        @datastream = fedora_object.datastreams[params[:download_id]]
        send_data @datastream.content, :filename=>@datastream.label, :type=>@datastream.attributes["mimeType"]
        #send_data( Fedora::Repository.instance.fetch_custom(params[:document_id], "datastreams/#{datastream_id}/content") )
      else
        @datastreams = downloadables( fedora_object )
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
    
    private
    
    def downloadables(fedora_object=@fedora_object)
      if editor? 
        if params["mime_type"] == "all"
          result = fedora_object.datastreams
        else
          result = Hash[]
          fedora_object.datastreams.each_pair do |dsid,ds|
           if ds.attributes["mimeType"].include?("pdf") || ds.label.include?("_TEXT.xml") || ds.label.include?("_METS.xml")
             result[dsid] = ds
           end  
          end
        end
      else
        result = Hash[]
        fedora_object.datastreams.each_pair do |dsid,ds|
           if ds.attributes["mimeType"].include?("pdf")
             result[dsid] = ds
           end  
         end
      end 
      return result    
    end
    
end