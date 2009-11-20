module MetadataHelper
  
  def metadata_field(resource, datastream_name, field_key, opts={})
    if datastream_name.nil?
      raise ArgumentError.new("This method expects arguments of the form (resource, datastream_name, field_key, opts={})") 
    end
    # If user does not have edit permission, display non-editable metadata
    # If user has edit permission, display editable metadata
    editable_metadata_field(resource, datastream_name, field_key, opts)
  end
  
  # Convenience method for creating editable metadata fields.  Defaults to creating multi-value field, but creates single-value field if :multiple => false
  def editable_metadata_field(resource, datastream_name, field_name, opts={})    
    if opts[:multiple] == false
      result = metadata_inline_edit(resource, datastream_name, field_name, opts)
    else
      result = editable_multi_value_field(resource, datastream_name, field_name, opts)
    end
    return result
  end
   
  def metadata_inline_edit(resource, datastream_name, field_name, opts={})
    if opts.has_key?(:label) 
      label = opts[:label]
    else
      label = field_name
    end
    resource_type = resource.class.to_s.underscore
    
    result = "<dt for=\"#{resource_type}_#{field_name}\">#{label}</dt>"    
    result << "<dd id=\"#{resource_type}_#{field_name}\"><span class=\"editableText\" id=\"#{resource_type}_#{field_name}\">#{get_values_from_datastream(resource, datastream_name, field_name).first}</span></dd>"
    return result
  end
  
  # Creates an editable field that allows addition of an arbitrary number of field values.
  def editable_multi_value_field(resource, datastream_name, field_key, opts={})
    field_name=field_key.to_s
    opts = {:ftype=>'field', :itype=>'editabletf'}.merge(opts)
    label = opts[:label] ?  opts[:label] : field_name.humanize.capitalize
    oid = resource.pid
    rel = url_for(:action=>"show")
    resource_type = resource.class.to_s.underscore
    fmt = "#{resource_type}_%s_%s_%d"
    fn=field_name.gsub(/_/, '+')
    new_element_id = fmt%[oid, fn, -1]
    
    result = ""
    result << "<dt id=\"#{field_name}\", class=\"field\">"
    result << label
    result << link_to_function("+" , "addLink()", :class=>'addmlink')
    result << "</dt>"
    
    #Output all of the current field values.
    datastream = resource.datastreams[datastream_name]
    vlist = datastream.fields[field_key][:values] || []
    vlist.each_with_index do |val,z|
      result << "<dd, id=\"#{fn}_#{z}\">" 
      result << link_to_remote(image_tag("delete.png"), :update => "", :url => {:action=>:show, "#{resource_type}[#{fn}][#{z}]"=>""}, :method => :put, :success => visual_effect(:fade, "#{fn}_#{z}"),:html => { :class  => "destructive" })
      result << "<span class=\"editableText values #{opts[:itype]}\" id=\"#{resource_type}_#{fn}_#{z}\">"
      result << ((val.blank? ?  "enter value" : h(val)))
      result << "</span>"
    end    
    
    return result
    # haml_tag(:div, {:id=>"#{field_name}", :class=>"field"}) do
    #   # Output the label and the + button for adding new values.
    #   haml_tag :label do
    #     puts "#{label}:"
    #     puts(link_to_function("+" , nil, :class=>'addmlink') do |page|
    #       #page.insert_html(:bottom, field_name,  "<div class=\"values #{opts[:itype]}\" id=\"#{fmt%[oid, fn, -1]}\" rel=\"#{rel}\">New</div>")
    #       #page << "Editable.create($('#{fmt%[oid, fn, -1]}'))"
    #       page.insert_html(:bottom, field_name, render(:partial=>"shared/new_field_value_form", :locals=>{:field_name=>fn,:oid=>oid,:resource_type=>resource_type,:rel=>rel, :element_id=>new_element_id}) )
    #       page << "Editable.create_active($('#{new_element_id}'))"
    #     end)
    #   end
    #   
    #   # Output all of the current field values.
    #   datastream = resource.datastreams[datastream_name]
    #   vlist = datastream.fields[field_key][:values] || []
    #   vlist.each_with_index do |val,z|
    #     haml_tag(:div, :id=>"#{fn}_#{z}") do
    #       puts link_to_remote(image_tag("delete.png"), :update => "", :url => {:action=>:show, "#{resource_type}[#{fn}][#{z}]"=>""}, :method => :put, :success => visual_effect(:fade, "#{fn}_#{z}"),:html => { :class  => "destructive" })
    #       haml_tag(:div, {:class=>"values #{opts[:itype]}",:id=>fmt%[oid, fn, z], :rel=>rel}) do
    #         puts((val.blank? ?  "enter value" : h(val)))
    #       end
    #     end
    #   end 
    # end
  end
  
  def get_values_from_datastream(resource, datastream_name, field_name)
    resource.datastreams[datastream_name].send("#{field_name}_values")
  end
  
  def custom_dom_id(resource)
    classname = resource.class.to_s.gsub(/[A-Z]+/,'\1_\0').downcase[1..-1]
    url = "#{classname}_#{resource.pid}"   
  end
  
end