module DownloadsHelper
  
  def list_downloadables( datastreams, mime_types=["application/pdf"])
    result = "<div id=\"downloads\"><ul>" 
           
    datastreams.each_value do |ds|
      result << "<li>"
      result << link_to(ds.label, document_downloads_path(ds.pid, :download_id=>ds.dsid))
      # if editor?
      #         result << " <span>#{ds.attributes["mimeType"]}</span>"
      #       end
      result << "</li>"     
    end
        
    result << "</ul></div>"
    return result
  end
  
end