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
    
    if opts.has_key?(:label) 
      label = opts[:label]
    else
      label = field_name
    end
    resource_type = resource.class.to_s.underscore
    
    result = "<dt for=\"#{resource_type}_#{field_name}\">#{label}</dt>"
    
    case opts[:type]
    when :text_area
      result << text_area_inine_edit(resource, datastream_name, field_name, opts)
    when :date_picker
      result << date_picker_inine_edit(resource, datastream_name, field_name, opts)
    else
      if opts[:multiple] == true
        result << multi_value_inline_edit(resource, datastream_name, field_name, opts)
      else
        result << single_value_inline_edit(resource, datastream_name, field_name, opts)
      end
    end
    return result
  end
  

  def single_value_inline_edit(resource, datastream_name, field_name, opts={})
    resource_type = resource.class.to_s.underscore
    opts[:default] ||= ""
    field_value = get_values_from_datastream(resource, datastream_name, field_name, opts).first
    result = "<dd id=\"#{resource_type}_#{field_name}\"><span class=\"editableText\" id=\"#{resource_type}[#{field_name}][0]\" rel=\"#{url_for(:action=>"update", :controller=>"documents")}\">#{field_value}</span></dd>"
    return result
  end
  
  def multi_value_inline_edit(resource, datastream_name, field_name, opts={})
    resource_type = resource.class.to_s.underscore

    rel = url_for(:action=>"update", :controller=>"documents")
    result = ""
    
    # result = ""
    # result << "<dt id=\"#{resource_type}_#{field_name}\", class=\"field\">"
    # result << label
    result << link_to_function("+" , "addAuthor()", :class=>'addmlink')
    # result << "</dt>"
    opts[:default] ||= ""
    #Output all of the current field values.
    datastream = resource.datastreams[datastream_name]
    vlist = get_values_from_datastream(resource, datastream_name, field_name, opts)
    vlist.each_with_index do |field_value,z|
      result << "<dd id=\"#{resource_type}_#{field_name}\">"
      result << link_to_remote(image_tag("delete.png"), :update => "", :url => {:action=>:show, "#{resource_type}[#{field_name}][#{z}]"=>""}, :method => :put, :success => visual_effect(:fade, "#{field_name}_#{z}"),:html => { :class  => "destructive" })
      result << "<span class=\"editableText\" id=\"#{resource_type}[#{field_name}][#{z}]\" rel=\"#{rel}\">#{field_value}</span>"
      result << "</dd>"
    end
    # sample tag for new value
    result << "<div class=\"new_field\" rel=\"#{rel}\" id=\"#{resource_type}[#{field_name}][-1]\" name=\"#{resource_type}[#{field_name}][-1]\"></div>"
    return result
  end

  def text_area_inine_edit(resource, datastream_name, field_name, opts={})
    resource_type = resource.class.to_s.underscore
    opts[:default] = "Text Area"
    field_value = get_values_from_datastream(resource, datastream_name, field_name, opts).first
    result = ""
    result << "<div id=\"#{resource_type}_#{field_name}\">"
    #result << "<span class=\"editableText\" id=\"#{resource_type}[#{field_name}][0]\" rel=\"#{url_for(:action=>"update", :controller=>"documents")}\">#{field_value}</span>"
    result << text_area_tag("#{resource_type}[#{field_name}][0]")
    result << "</div>"
    result << "<div id=\"textareaAbstract\">#{field_value}</div>"
    result << "<div class=\"boxSaveCancel marginTop_40\" id=\"abstractSaveCancelBox\">"
    result << "  <input type=\"button\" value=\"Save\" class=\"buttonSave button\" onclick=\"javascript: saveAbstract(); return true;\" />"
    result << "  <input type=\"button\" value=\"Cancel\" class=\"buttonCancel\" onclick=\"javascript:hideAbstractSaveCancelBox();return true;\" />"
    result << "</div>"
    result << "<div class=\"boxSaveProcessing marginTop_40\" id=\"savingAbstract\" style=\"display:none;\">Saving..</div>"
    return result
  end
  
  def date_picker_inine_edit(resource, datastream_name, field_name, opts={})
    resource_type = resource.class.to_s.underscore
    field_value = get_values_from_datastream(resource, datastream_name, field_name, opts).first
    result = "<dd id=\"#{resource_type}_#{field_name}\"><span class=\"editableText\" id=\"#{resource_type}[#{field_name}][0]\" rel=\"#{url_for(:action=>"update", :controller=>"documents")}\">#{field_value}</span></dd>"
    return result
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