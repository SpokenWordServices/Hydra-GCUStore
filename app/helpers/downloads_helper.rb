module DownloadsHelper
  
  def list_downloadables( fedora_object )
    result = ""
    fedora_object.datastreams.each_value do |ds|
      #if ds.label.include?(".pdf") 
        result << "<li>"
        #result << ds.label
        result << link_to(ds.label, document_downloads_path(fedora_object.pid, :download_id=>ds.dsid))
        result << "</li>"
      #end
    end
    return result
  end
  
end