require 'blacklight/catalog_helper_behavior'
module CatalogHelper
  include Blacklight::CatalogHelperBehavior
  include ActionView::Helpers::TextHelper
	include HullAccessControlEnforcement

  def get_persons_from_roles(doc,roles,opts={})
    i = 0
    persons =[]
    while i < 20
      persons_roles = [] # reset the array
      persons_roles = doc["person_#{i}_role_t"].map{|w|w.strip.downcase.split} unless doc["person_#{i}_role_t"].nil?
      if persons_roles and (persons_roles.flatten & roles.map{|x|x.downcase}).length > 0  #lower_cased roles for examples such as Supervisor
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

  
  #Method to display parent collections as links

  def display_parent_collections(document)

    text=""
    parents = document.display_sets
    if parents.kind_of?(Array) and parents.count > 0
      unless parents.count == 1 && parents.first == "info:fedora/hull:rootDisplaySet"
        text = <<-EOS
        <div id="collections" >
          <fieldset id="collection-fields">
          <legend>#{pluralize(parents.count,"In Collection")[2..-1]}</legend>
          <div id="collections-list">
            <dl>
        EOS
        parents.each { |id| 
          pid=id.partition("/")[2]
          text << <<-EOS
              <dt>
          EOS
          text << link_to(DisplaySet.name_of_set(pid), resource_path(pid)) 
          text << <<-EOS
              </dt>
          EOS
        }
        text << <<-EOS
            </dl>
          </div>
         </fieldset>
        </div>
        EOS
      end
    end 
    
    text.html_safe
  end 


#This helper method will create a list of downloadable assets for a 
  #resource.
  #It also adds a google event tracker call to the link, in the form of:-
  #onClick="_gaq.push(['_trackEvent','Downloads', 'Resource title', 'PID/DsID'])  
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

     resource_title = get_values_from_datastream(document, "descMetadata",[:title])
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
      resources << <<-EOS
         <div id="download"> 
	         <div id="download_image" class="#{download_image_class_by_mime_type(mime_type[i])}" ></div>
           <a href="/assets/#{object_id[i]}/#{ds_id[i]}" onClick="_gaq.push(['_trackEvent','Downloads', '#{object_id[i]}/#{ds_id[i]}', '#{resource_title}']);">#{display_label[i]}</a> 
EOS
   
       resources << <<-EOS
           <div id="file-size">(#{get_friendly_file_size(file_size[i])} #{format[i]})
      EOS

      #If the content is a KMZ or a KML file and less then 3MB...
      if (mime_type[i].eql?("application/vnd.google-earth.kmz") || mime_type[i].eql?("application/vnd.google-earth.kml+xml"))
        if file_size[i].to_i > 0 && file_size[i].to_i < 3145728
          # And if the document is public readable... We display a link to the Google maps View of the map - Google maps need the KML/KMZ to be public accessible...
          if is_public_readable(document)
            resources << <<-EOS
              <div id="view-map-link">
              <a href="/google_map.html?object_id=#{object_id[i]}&ds_id=#{ds_id[i]}" target="_blank">View as map<a></div>
            EOS
          end
        end
      end

     resources << <<-EOS
        </div>
       </div>
     EOS

     end
      resources << <<-EOS
        </div>
       </fieldset>
      EOS
    end
    resources.html_safe
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

  def browse_structural_sets_link
    if current_user
      if RoleMapper.roles(current_user.login).include? 'contentAccessTeam'
        link_to "Browse sets", "?f%5Bis_member_of_s%5D%5B%5D=info:fedora/hull:rootSet&results_view=true" 
      end
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
    datastream_field.html_safe
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
    datastream_field.html_safe
  end

# This does exactly the same as display_datastream_field but takes in additional field which should contain the link	
	def display_datastream_field_as_link(document,datastream_name,fields=[],link=[],label_text='',dd_class=nil)
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
            <a href="#{get_values_from_datastream(document,datastream_name, link).first}">#{get_values_from_datastream(document,datastream_name, fields).join("; ")}</a>
        </dd>
      EOS
    end
    datastream_field.html_safe
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
    datastream_text_area_field.html_safe
	end


  def display_object_group_permissions(document, permission_ds)
    groups = document.datastreams[permission_ds].groups

    unless groups.nil?
      permissions = <<-EOS
         <fieldset>
           <dl>
           <dt><strong>Default permissions</strong></dt><dd></dd>
      EOS
      groups.each do |group|
        group_permission = group[1].to_s
      
        case group_permission
        when "read"
          group_display = "Read and download"
        when "edit"
          group_display = "Edit"
        when "discover"
          group_display = "Search and discover" 
        else
          group_display = group_permission       
        end

        permissions << <<-EOS
            <dt>
             #{group[0]}
            </dt>
            <dd class="dd_text">
              #{group_display}
            </dd>
        EOS
      end 
    end
    permissions << <<-EOS
          </dl>
         </fieldset>
     EOS
    permissions.html_safe
  end

  def display_qr_code
    qr_code=""
    #Possibly insert, once we have changed the styles <div class="link-title">QR code</div>
    qr_code << <<-EOS
      <div id="qr_code">
       <img id="qr-image" src="https://chart.googleapis.com/chart?cht=qr&chl=#{request.url}&chs=120x120" alt="QR Code" title="QR Code"/>
      </div>
    EOS
    qr_code.html_safe
  end

  def download_image_class_by_mime_type(mime_type)    
    image_class = case mime_type
    when "application/pdf"
      "pdf-download"
    when "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "doc-download"
    when "image/gif", "image/jpg", "image/jpeg", "image/bmp"
      "img-download"
    when "video/avi", "video/mpeg", "video/quicktime", "video/x-ms-wmv", "video/mp4"
      "vid-download"
    when "audio/aiff", "audio/midi", "audio/mpeg", "audio/x-pn-realaudio", "audio/wav", "audio/mp4"
      "sound-download"
    when "application/vnd.openxmlformats-officedocument.presentationml.presentation", "application/vnd.ms-powerpoint"
      "presentation-download"
    when "application/excel", "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "spreadsheet-download"
    when "application/zip"
      "zip-download"
    when "application/vnd.google-earth.kmz", "application/vnd.google-earth.kml+xml"
      "kmlz-download"
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
  text = ""
  if size_in_bytes_str.length > 0
		begin
    	size_in_bytes = Float(size_in_bytes_str)
			text = bits_to_human_readable(size_in_bytes).to_s
		rescue ArgumentError
			text = ""
		end
  end
  text  
 end

 def bits_to_human_readable(num)
   ['bytes','KB','MB','GB','TB'].each do |x|
    if num < 1024.0
     return "#{num.to_i} #{x}"
    else
     num = num/1024.0
     end
    end
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

  def breadcrumb_trail_for_set(pid)
		#Objects ids are stored as "info:fedora/hull:3374" in tree so we need to append this
		content = "info:fedora/" + pid
		breadcrumb = ""
		structural_set_tree = StructuralSet.tree    
		current_node = ""		
		structural_set_tree.each do |node|
	    if node.content == content
        current_node = node
        break
      end
		end
		if current_node != ""			
			parentage_sets = current_node.parentage.reverse
			parentage_sets.each do |set| 
				pid = set.content.slice(set.content.index('/')  + 1..set.content.length)
				name = set.name
				breadcrumb << link_to(name, "/?f%5Bis_member_of_s%5D%5B%5D=info:fedora/#{pid}&results_view=true") if parentage_sets.first == set
				breadcrumb << link_to(name , resource_path(pid)) if parentage_sets.first != set
				breadcrumb << " &gt; " if parentage_sets.last != set
			end
		end
		breadcrumb.html_safe
  end

  #Helper for displaying a relevant icon for a resource index page
  def display_resource_icon(document)

   #Set the queue_name if it isn't nil
   if !(document["is_member_of_queue_facet"].nil?) then queue_name = document["is_member_of_queue_facet"].first else queue_name = "" end
 
   #We set a different img_class genre if its in hidden or deleted queue
   if ((queue_name.include? "Deleted") || (queue_name.include? "Hidden"))
    case queue_name
    when "Deleted"
      img_class = "deleted-genre"
    when "Hidden"
      img_class = "hidden-genre" 
    end
   else
     #standard icons
     genre = document["genre_t"].to_s.downcase
     case genre
     when "structural set", "structuralset" 
      img_class = "structural-set-genre"
     when "display set"
      img_class = "collection-genre"
     when "presentation"
      img_class = "presentation-genre"
     when "photograph", "artwork"
      img_class = "image-genre"
     when "meeting papers or minutes"
      img_class = "event-genre"
     when "audio"
      img_class = "sound-genre"
     when "video"
      img_class = "video-genre"
     else
      img_class = "text-genre"
     end
   end

   resource_icon = <<-EOS
     <div id="genre_image" class="#{img_class}"></div>
   EOS

   resource_icon.html_safe
  end


  # Helpers copied from Graeme's work - might need tweeking
  def fedora_content_url pid, datastream_name

    return serve_datastream_content_url :id=>pid, :datastream_id=>datastream_name    

#    begin
#      base_url = ActiveFedora.fedora().connection.config[:url]
#    rescue
#      base_url = "http://localhost:8983/fedora"
#    end
#    "#{base_url}/get/#{pid}/#{datastream_name}"
  end
  
  

 # Get content mime-type (or rather just the file format) - used for sending info to jwplayer

  def get_content_format(document, datastream_name, dsid)
 
     ds_ids = get_values_from_datastream(document, datastream_name,[:resource, :resource_ds_id])  
     formats = get_values_from_datastream(document, datastream_name ,[:resource, :file, :format])
     formats[ds_ids.index(dsid)]
  
  end

 # Get display resolution for jwplayer
  def get_video_display_resolution(document,datastream_name, dsid)

  #default values
    height="288"
    width="512"

    metadata = document.datastreams[datastream_name]

    if metadata.kind_of?(ActiveFedora::NokogiriDatastream)   
      xpath_to_file="//xmlns:resource[@dsID='#{dsid}']/xmlns:file/xmlns:videoData/"
      video_height=metadata.find_by_xpath(xpath_to_file+"@height").to_s
      video_width=metadata.find_by_xpath(xpath_to_file+"@width").to_s

      if  !video_height.empty? and  !video_width.empty? 
      #scale display to fit within limits
        aspect_ratio=video_height.to_f/video_width.to_f
        if (aspect_ratio - 0.5625).abs < 0.0001
          #leave as default
        elsif (aspect_ratio - 0.75).abs < 0.0001
          #4:3
          width="384"
        else
          #scale to max width
          height=(512*aspect_ratio).ceil.to_s
        end
      end
    end
    return {:height=>height, :width=>width}
  end

 def is_public_readable(document)
    
  public_readable = false

  public_permissions = document.rightsMetadata.groups["public"]  
  #Check what public permissions contain...
  if !public_permissions.nil? 
    if public_permissions.include? "read"
      public_readable = true
    end
  end 

  return public_readable 

 end



end

