module CatalogHelper
  include ActionView::Helpers::TextHelper
	include HullAccessControlEnforcement
  require_dependency "vendor/plugins/hydra_repository/app/helpers/catalog_helper.rb"

  def get_persons_from_roles(doc,roles,opts={})
    i = 0
    persons =[]
    while i < 10
      persons_roles = [] # reset the array
      persons_roles = doc["person_#{i}_role_t"].map{|w|w.strip.downcase} unless doc["person_#{i}_role_t"].nil?
      if persons_roles and (persons_roles & roles.map{|x|x.downcase}).length > 0  #lower_cased roles for examples such as Supervisor
        persons << {:name => doc["person_#{i}_namePart_t"],:role => doc["person_#{i}_role_t"], :affiliation => doc["person_#{i}_affiliation_t"], :person_index=>"#{i}" }
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
        orgs << {:name => doc["organization_#{i}_namePart_t"],:role => doc["organization_#{i}_role_t"], :org_index => "#{i}"}
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
        <fieldset id="download_fields">
        <legend>#{pluralize(resources_count,"Download")[2..-1]}</legend>
        <div id="downloads-list">
     EOS

     display_label = get_values_from_datastream(document, "contentMetadata",[:resource, :display_label])
     object_id = get_values_from_datastream(document, "contentMetadata",[:resource, :resource_object_id])
     ds_id = get_values_from_datastream(document, "contentMetadata",[:resource, :resource_ds_id])  
     mime_type = get_values_from_datastream(document, "contentMetadata",[:resource, :file, :mime_type])
     format = get_values_from_datastream(document, "contentMetadata",[:resource, :file, :format])
     file_size = get_values_from_datastream(document, "contentMetadata",[:resource, :file, :size])
    
     sequence = get_values_from_datastream(document, "contentMetadata",[:resource,:sequence])

     sequence_hash = {}
     sequence.each_with_index{|v,i| sequence_hash[v.to_i] = i }

     sequence_hash.keys.sort.each do |seq| 
        i = sequence_hash[seq]
#     while i < resources_count
      resources << <<-EOS 
	       <div id="download_image" class="#{download_image_class_by_mime_type(mime_type[i])}" ></div>
           <a href="/assets/#{object_id[i]}/#{ds_id[i]}">#{display_label[i]}</a> 
           <div id="file-size">(#{get_friendly_file_size(file_size[i])}, #{format[i]})</div>
      EOS
#       i += 1
     end
      resources << <<-EOS
        </div>
       </fieldset>
      EOS
   end
      resources 
  end
  
	def display_edit_form(document_fedora, content_type)
		#Pluralize the content type to get the correct part for path...
		pluralized_content_type = pluralize(2, content_type)[2..-1]
		
		#When object is in proto queue, you always get the standard edit form...
		if document_fedora.queue_membership.include?(:proto)
			render :partial => pluralized_content_type + '/edit_description'
		else
			render :partial => pluralized_content_type + '/edit_description_qa'
		end		
	end

	def create_resource_link
		if has_create_permissions
			  link_to "Create Resource", :controller => "work_flow", :action => "new"
		end
	end

  def display_datastream_field(document,datastream_name,fields=[],label_text='',dd_class=nil)
    label = ""
    dd_class = "class=\"#{dd_class}\"" if dd_class
    datastream_field = ""
	 	unless get_values_from_datastream(document,datastream_name, fields).first.empty?
      if label_text.length > 0
        label = pluralize(get_values_from_datastream(document,datastream_name, fields).count,label_text)[2..-1]
      end
      datastream_field = <<-EOS
        <dt>
          #{fedora_field_label(datastream_name,fields,label)}
        </dt>
        <dd #{dd_class}>
            #{get_values_from_datastream(document,datastream_name, fields).join("; ")}
        </dd>
      EOS
    end
    datastream_field
  end

	# This does exactly the same as display_datastream_field but uses display_friendly_date to display date content
  # more appropriately	
	def display_datastream_date_field(document,datastream_name,fields=[],label_text='',dd_class=nil)
    label = ""
    dd_class = "class=\"#{dd_class}\"" if dd_class
    datastream_field = ""
	 	unless get_values_from_datastream(document,datastream_name, fields).first.empty?
      if label_text.length > 0
        label = pluralize(get_values_from_datastream(document,datastream_name, fields).count,label_text)[2..-1]
      end
      datastream_field = <<-EOS
        <dt>
          #{fedora_field_label(datastream_name,fields,label)}
        </dt>
        <dd #{dd_class}>
            #{display_friendly_date(get_values_from_datastream(document,datastream_name, fields)[0])}
        </dd>
      EOS
    end
    datastream_field
  end

	# This does exactly the same as display_datastream_field but uses simple format to display text area content
  # more appropriately
	def display_datastream_text_area_field(document,datastream_name,fields=[],label_text='',dd_class=nil)
    label = ""
    dd_class = "class=\"#{dd_class}\"" if dd_class
    datastream_text_area_field = ""
	 	unless get_values_from_datastream(document,datastream_name, fields).first.empty?
      if label_text.length > 0
        label = pluralize(get_values_from_datastream(document,datastream_name, fields).count,label_text)[2..-1]
      end
      datastream_text_area_field = <<-EOS
        <dt>
          #{fedora_field_label(datastream_name,fields,label)}
        </dt>
        <dd #{dd_class}>
            #{simple_format(get_values_from_datastream(document,datastream_name, fields).join("; "))}
        </dd>
      EOS
    end
    datastream_text_area_field
	end

  def display_qr_code
    qr_code=""
    #Possibly insert, once we have changed the styles <div class="link-title">QR code</div>
    qr_code << <<-EOS
      <div id="qr_code">
       <img src="http://chart.apis.google.com/chart?cht=qr&chl=#{request.url}&chs=120x120" alt="QR Code" title="QR Code"/>
      </div>
    EOS
    qr_code
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

 def display_friendly_date(date)
		display_date = date
		if date.match(/^\d{4}-\d{2}$/)
			display_date = Date.parse(to_long_date(date)).strftime("%B") + " " + Date.parse(to_long_date(date)).strftime("%Y")
		elsif date.match(/^\d{4}-\d{2}-\d{2}$/)
			display_date = Date.parse(date).day().to_s + " " + Date.parse(date).strftime("%B") + " " + Date.parse(date).strftime("%Y")
		end
		return display_date
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

	#Quick utility method used to get long version of a date (YYYY-MM-DD) from short form (YYYY-MM) - Defaults 01 for unknowns - Exists in hull_model_methods too
	def to_long_date(flexible_date)
		full_date = ""
		if flexible_date.match(/^\d{4}$/)
			full_date = flexible_date + "-01-01"
		elsif flexible_date.match(/^\d{4}-\d{2}$/)
			full_date = flexible_date +  "-01"
		elsif flexible_date.match(/^\d{4}-\d{2}-\d{2}$/)
			full_date = flexible_date
		end
		return full_date
	end  

end

