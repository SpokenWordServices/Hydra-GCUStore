module CatalogHelper

  require_dependency "vendor/plugins/hydra_repository/app/helpers/catalog_helper.rb"


  def get_persons_from_roles(doc,roles,opts={})
    i = 0
    persons =[]
    while i < 10
      persons_roles = [] # reset the array
      persons_roles = doc["person_#{i}_role_t"].map{|w|w.strip.downcase} unless doc["person_#{i}_role_t"].nil?
      if persons_roles and (persons_roles & roles).length > 0
        persons << {:name => doc["person_#{i}_namePart_t"],:role => doc["person_#{i}_role_t"]}
      end
      i += 1
    end
    return persons
  end 

  def get_organizations_from_roles(doc,roles,opts={})
    i = 0
    orgs = []
    while i < 10
      orgs_roles = []
      orgs_roles = doc["organization_#{i}_role_t"].map{|w|w.strip.downcase} unless doc["organization_#{i}_role_t"].nil?
      if orgs_roles and (orgs_roles & roles).length > 0
        orgs << {:name => doc["organization_#{i}_namePart_t"],:role => doc["organization_#{i}_role_t"]}
      end
      i += 1
    end
    return orgs
  end 

  def display_resources(document)

   resources_count = get_values_from_datastream(document, "contentMetadata", [:resource]).length
   resources = ""

   if resources_count > 0
     i = 0
     resources = <<-EOS
        <div id="downloads-list">
     EOS

     display_label = get_values_from_datastream(document, "contentMetadata",[:resource, :display_label])
     object_id = get_values_from_datastream(document, "contentMetadata",[:resource, :resource_object_id])
     ds_id = get_values_from_datastream(document, "contentMetadata",[:resource, :resource_ds_id])
     mime_type = get_values_from_datastream(document, "contentMetadata",[:resource, :file, :mime_type])
     file_size = get_values_from_datastream(document, "contentMetadata",[:resource, :file, :size])

     while i < resources_count
      resources << <<-EOS 
	   <div><div id="download_image" class="#{download_image_class_by_mime_type(mime_type[i])}" ></div>
           <a href="/assets/#{object_id[i]}/genericContent/#{ds_id[i]}">#{display_label[i]}</a>
           <div id="file-size">(#{get_friendly_file_size(file_size[i])})</div>
      EOS
       i += 1
     end
      resources << <<-EOS
        </div>
      EOS
   end
      resources 
  end


  def display_datastream_field(document,datastream_name,fields=[],label_text='',dd_class=nil)
    dd_class = "class=\"#{dd_class}\"" if dd_class
    datastream_field = ""
	 	unless get_values_from_datastream(document,datastream_name, fields).first.empty?
      datastream_field = <<-EOS
        <dt>
          #{fedora_field_label(datastream_name,fields,label_text)}:
        </dt>
        <dd #{dd_class}>
            #{get_values_from_datastream(document,datastream_name, fields).join("; ")}
        </dd>
      EOS
    end
    datastream_field
  end



  def download_image_class_by_mime_type(mime_type)    
    image_class = case mime_type
    when "application/pdf"
      "pdf-download"
    when "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "doc-download"
    when "image/gif", "image/jpg", "image/jpeg", "image/bmp"
      "img-download"
    when "video/avi", "video/mpeg", "video/quicktime", "video/x-ms-wmv"
      "vid-download"
    when "audio/aiff", "audio/midi", "audio/mpeg", "audio/x-pn-realaudio", "audio/wav"
      "sound-download"
    when "application/vnd.openxmlformats-officedocument.presentationml.presentation", "application/vnd.ms-powerpoint"
      "presentation-download"
    when "application/excel", "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "spreadsheet-download"
    when "application/zip"
      "zip-download"
    else
      "generic-download"
    end
 end


 def get_friendly_file_size(size_in_bytes_str)
  text = "Size n/a"   
  if size_in_bytes_str.length > 0
    size_in_bytes = Integer(size_in_bytes_str)
    if size_in_bytes > 1048575
      friendly_file_size = size_in_bytes / 1024 / 1024
      text = friendly_file_size.to_s + "MB"
    else
     friendly_file_size = size_in_bytes / 1024
     text = friendly_file_size.to_s + "KB"
    end
  end
  text  
 end  

end

