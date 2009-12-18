require 'mediashelf/active_fedora_helper'
class GetController < ApplicationController
    include MediaShelf::ActiveFedoraHelper
    include Stanford::SaltControllerHelper
    helper :downloads
    
    before_filter :require_fedora
    
    def show
      fedora_object = ActiveFedora::Base.load_instance(params[:id])
      
      respond_to do |format|
        format.html { send_datastream downloadables( fedora_object, :canonical=>true ) }
        format.pdf { send_datastream downloadables( fedora_object, :canonical=>true, :mime_type=>"application/pdf" ) }
        format.jp2 do 
          canonical_jp2 = downloadables( fedora_object, :canonical=>true, :mime_type=>"image/jp2" )
          if params["image_server"]
            if params["image_server"]["scale"] 
              send_data Djatoka.scale(canonical_jp2.url, params["image_server"]["scale"]), :type=>"image/jpeg"
            elsif   params["image_server"]["region"] 
              send_data Djatoka.region(canonical_jp2.url, params["image_server"]["region"]), :type=>"image/jpeg"
            else
              send_data Djatoka.get_image(canonical_jp2.url, params["image_server"]["region"]), :type=>"image/jpeg"
            end
          else
            send_datastream canonical_jp2
          end
        end
      end
      
    end
    
    private
    def send_datastream(datastream)
      send_data datastream.content, :filename=>datastream.label, :type=>datastream.attributes["mimeType"]
    end
    
end