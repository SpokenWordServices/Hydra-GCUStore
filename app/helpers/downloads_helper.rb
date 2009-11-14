module DownloadsHelper
  
  def list_downloadables( fedora_object, mime_types=["application/pdf"])
    result = "<div id=\"downloads\"><ul>"
    fedora_object.datastreams.each_value do |ds|
      if mime_types == :all
        result << "<li>"
        result << link_to(ds.label, document_downloads_path(fedora_object.pid, :download_id=>ds.dsid))
        result << "<span>#{ds.attributes["mimeType"]}</span>"
        result << "</li>"
      else
        mime_types.each do |mime_type|
          if ds.attributes["mimeType"].include?(mime_type)
            result << "<li>"
            result << link_to(ds.label, document_downloads_path(fedora_object.pid, :download_id=>ds.dsid))
            result << "</li>"
          end
        end
      end
    end
    result << "</ul></div>"
    return result
  end
  
end