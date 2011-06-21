require "inline_editable_metadata_helper"
require "block_helpers"
require "vendor/plugins/hydra_repository/app/helpers/hydra_fedora_metadata_helper.rb"

module HydraFedoraMetadataHelper
  # Overwritten to provide more flexibility in the output of text_fields
  # 
  # Any html options can be passed in the opts hash using :html_options=>{}
  def fedora_text_field(resource, datastream_name, field_key, opts={})
    field_name = field_name_for(field_key)
    field_values = get_values_from_datastream(resource, datastream_name, field_key, opts)
    if opts.fetch(:multiple, true)
      container_tag_type = :li
    else
      field_values = [field_values.first]
      container_tag_type = :span
    end
    
    html_options = opts.keys.include?(:html_options) ? opts[:html_options] : {}

    body = ""
    
    field_values.each_with_index do |current_value, z|
      base_id = generate_base_id(field_name, current_value, field_values, opts)
      name = "asset[#{datastream_name}][#{field_name}][#{z}]"
      body << "<#{container_tag_type.to_s} class=\"editable-container field\" id=\"#{base_id}-container\">"
        delete_link= field_key_specific_delete_link(field_name,z,resource.pid,image_tag("/images/remove.png",:border=>0), current_value)
        body << "<span class=\"editable-text text\" id=\"#{base_id}-text\">#{h(current_value)}</span>"
        html_options.merge!({:class=>"editable-edit edit", 'data-datastream-name' => datastream_name, :rel => field_name,:id=>base_id})
        inputtag = text_field_tag name, h(current_value), html_options
        body << inputtag
        body << delete_link unless z == 0
      body << "</#{container_tag_type}>"
    end
    result = field_selectors_for(datastream_name, field_key)
    if opts.fetch(:multiple, true)
      result << content_tag(:ol, body, :rel=>field_name)
    else
      result << body
    end
    
    return result
  end

  # The following method is being altered in order to provide a progressively enhancable text area
  # The main change is adding a textarea tag that does not need to be initialized from javascript
  # Textile textarea varies from the other methods in a few ways
  # Since we're using jeditable with this instead of fluid, we need to provide slightly different hooks for the javascript
  # * we are storing the datastream name in data-datastream-name so that we can construct a load url on the fly when initializing the textarea
  def fedora_textile_text_area(resource, datastream_name, field_key, opts={})
    field_name = field_name_for(field_key)
    field_values = get_values_from_datastream(resource, datastream_name, field_key, opts)
    if opts.fetch(:multiple, true)
      container_tag_type = :li
    else
      field_values = [field_values.first]
      container_tag_type = :span
    end
    body = ""

    field_values.each_with_index do |current_value, z|
      base_id = generate_base_id(field_name, current_value, field_values, opts)
      name = "asset[#{datastream_name}][#{field_name}][#{z}]"
      processed_field_value = white_list( RedCloth.new(current_value, [:sanitize_html]).to_html)
      
      body << "<#{container_tag_type.to_s} class=\"field_value textile-container field\" id=\"#{base_id}-container\">"
        # Not sure why there is we're not allowing the for the first textile to be deleted, but this was in the original helper.
        body << "<a href=\"\" title=\"Delete '#{h(current_value)}'\" class=\"destructive field\">Delete</a>" unless z == 0
        body << "<div class=\"textile-text text\" id=\"#{base_id}-text\">#{processed_field_value}</div>"
        body << "<input class=\"textile-edit edit\" id=\"#{base_id}\" data-datastream-name=\"#{datastream_name}\" rel=\"#{field_name}\" name=\"#{name}\" value=\"#{h(current_value)}\"/>"
        body << "<textarea class=\"textarea-edit edit\" id=\"#{base_id}\" data-datastream-name=\"#{datastream_name}\" rel=\"#{field_name}\" name=\"#{name}\">#{h(current_value)}</textarea>"
      body << "</#{container_tag_type}>"
    end
    
    result = field_selectors_for(datastream_name, field_key)
    
    if opts.fetch(:multiple, true)
      result << content_tag(:ol, body, :rel=>field_name)
    else
      result << body
    end
    
    return result
    
  end

  def field_key_specific_delete_link(field_key, index, asset_id, text, current_value)
    if field_key.match /^subject_\d+_topic$/
        delete_link = link_to text, subject_topic_path(:asset_id=>asset_id,:index=>index,:content_type=>@content_type), :method=>"delete", :class=>"destructive field", :title=>"Delete #{h(current_value)}"
    elsif field_key.match /^grant/
      delete_link = link_to text, grant_path(:asset_id=>asset_id,:index=>index,:content_type=>@content_type), :method=>"delete", :class=>"destructive field", :title=>"Delete #{h(current_value)}"
    else
      delete_link = "<a href=\"\" title=\"Delete '#{h(current_value)}'\" class=\"destructive field\" src=\"/images/remove.png\">Delete</a>"
    end

    return delete_link

  end
  
end
