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
      result = metadata_form_field(resource, datastream_name, field_name, opts)
    else
      result = metadata_form_field(resource, datastream_name, field_name, opts)
    end
    return result
  end
   
  def metadata_form_field(resource, datastream_name, field_name, opts={})
    if opts.has_key?(:label) 
      label = opts[:label]
    else
      label = field_name
    end
    resource_type = resource.class.to_s.underscore
    
    result = "<label for=\"#{resource_type}_#{field_name}\">#{label}</label>"    
    result << "<input type=\"text\" id=\"#{resource_type}_#{field_name}\" name=\"#{resource_type}[#{field_name}]\" value=\"#{get_values_from_datastream(resource, datastream_name, field_name).first}\" />"
    return result
  end
  
  def get_values_from_datastream(resource, datastream_name, field_name)
    resource.datastreams[datastream_name].send("#{field_name}_values")
  end
  
  def custom_dom_id(resource)
    classname = resource.class.to_s.gsub(/[A-Z]+/,'\1_\0').downcase[1..-1]
    url = "#{classname}_#{resource.pid}"   
  end
  
end