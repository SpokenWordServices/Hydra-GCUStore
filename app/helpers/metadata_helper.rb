module MetadataHelper
  
  def metadata_field(resource, datastream_name, field_key, opts={})
    if datastream_name.nil?
      raise ArgumentError.new("This method expects arguments of the form (resource, datastream_name, field_key, opts={})") 
    end
    # If user does not have edit permission, display non-editable metadata
    # If user has edit permission, display editable metadata
    editable_metadata_field(resource, datastream_name, field_key, opts)
  end
  
  # Convenience method for creating editable metadata fields.  Defaults to creating single-value field, but creates multi-value field if :multiple => true
  # Field name can be provided as a string or a symbol (ie. "title" or :title)
  def editable_metadata_field(resource, datastream_name, field_key, opts={})    
    field_name=field_key.to_s
    if opts[:multiple] == true
      result = multi_value_inline_edit(resource, datastream_name, field_name, opts)
    else
      result = single_value_inline_edit(resource, datastream_name, field_name, opts)
    end
    return result
  end
  

  def single_value_inline_edit(resource, datastream_name, field_name, opts={})
    p "single_value_inline_edit triggered for #{datastream_name} #{field_name} "
    if opts.has_key?(:label) 
      label = opts[:label]
    else
      label = field_name
    end
    resource_type = resource.class.to_s.underscore
    
    result = "<dt for=\"#{resource_type}_#{field_name}\">#{label}</dt>"    
    field_value = get_values_from_datastream(resource, datastream_name, field_name, opts).first
    result << "<dd id=\"#{resource_type}_#{field_name}\"><span class=\"editableText\" id=\"#{resource_type}[#{field_name}][0]\" rel=\"#{url_for(:action=>"update", :controller=>"documents")}\">#{field_value}</span></dd>"
    return result
  end
  
  def multi_value_inline_edit(resource, datastream_name, field_name, opts={})
    p "multi_value_inline_edit triggered for #{datastream_name} #{field_name} "
    
    if opts.has_key?(:label) 
      label = opts[:label]
    else
      label = field_name
    end
    resource_type = resource.class.to_s.underscore
    
    result = ""
    result << "<dt id=\"#{resource_type}_#{field_name}\", class=\"field\">"
    result << label
    result << link_to_function("+" , "addLink()", :class=>'addmlink')
    result << "</dt>"
    
    resource_type = resource.class.to_s.underscore
    
    #Output all of the current field values.
    datastream = resource.datastreams[datastream_name]
    vlist = datastream.fields[field_name.to_sym][:values] || []
    vlist.each_with_index do |field_value,z|
      # link to remove   --- !!! This doesn't work because of some insane Rails engines conflict that prevents us from using helpers.
      result << "<dd id=\"#{resource_type}_#{field_name}\">"
      result << link_to_remote(image_tag("delete.png"), :update => "", :url => {:action=>:show, "#{resource_type}[#{field_name}][#{z}]"=>""}, :method => :put, :success => visual_effect(:fade, "#{field_name}_#{z}"),:html => { :class  => "destructive" })
      result << "<span class=\"editableText\" id=\"#{resource_type}[#{field_name}][#{z}]\" rel=\"#{url_for(:action=>"update", :controller=>"documents")}\">#{field_value}</span>"
      result << "</dd>"
    end
    # hidden new value
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
  
  def get_values_from_datastream(resource, datastream_name, field_name, opts={})
    result = resource.datastreams[datastream_name].send("#{field_name}_values")
    if result.empty? && opts[:default]
      result = [opts[:default]]
    end
    return result
  end
  
  def custom_dom_id(resource)
    classname = resource.class.to_s.gsub(/[A-Z]+/,'\1_\0').downcase[1..-1]
    url = "#{classname}_#{resource.pid}"   
  end
  
end