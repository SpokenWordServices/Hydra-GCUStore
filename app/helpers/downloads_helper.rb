module DownloadsHelper
  
  def list_downloadables( fedora_object )
    result = "<div id=\"downloads\"><ul>"
    fedora_object.datastreams.each_value do |ds|
      if ds.attributes["mimeType"].include?("pdf")
        result << "<li>"
        result << link_to(ds.label, document_downloads_path(fedora_object.pid, :download_id=>ds.dsid))
        result << "</li>"
      end
    end
    result << "</ul></div>"
    return result
  end
  
end