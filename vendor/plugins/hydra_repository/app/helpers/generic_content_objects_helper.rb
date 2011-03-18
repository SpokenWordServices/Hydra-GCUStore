module GenericContentObjectsHelper
  
  def disseminator_link pid, datastream_name
    "<a class=\"fbImage\" href=\"#{ datastream_content_url(pid, datastream_name) }\">view</a>"
  end
  
end
