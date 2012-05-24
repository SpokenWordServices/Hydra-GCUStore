require "inline_editable_metadata_helper"
require "block_helpers"
module HydraFedoraMetadataHelper
  include Hydra::HydraFedoraMetadataHelperBehavior

  def fedora_hidden_field(resource, datastream_name, field_key, opts={})
    field_name, field_values, container_tag_type = get_field_info_and_container_tag(resource, datastream_name, field_key, opts)
    
    if opts.fetch(:forced_values,nil)
      field_values = opts[:forced_values]
    end

    html_options = opts.fetch(:html_options,{})
    
    body = ""

    field_values.each_with_index do |current_value, index|
      base_id = generate_base_id(field_name, current_value, field_values, opts)
      
      html_options.merge!({'data-datastream-name' => datastream_name, :rel=>field_name, :id=> base_id})
      hiddentag = hidden_field_tag get_name(datastream_name, field_name, index), h(current_value), html_options
      body << hiddentag
    end
    result = field_selectors_for(datastream_name,field_key)
    result << body.html_safe
    result
  end

  # Overwritten to provide more flexibility in the output of text_fields
  # 
  # Any html options can be passed in the opts hash using :html_options=>{}
  def fedora_text_field(resource, datastream_name, field_key, opts={})
    field_name, field_values, container_tag_type = get_field_info_and_container_tag(resource, datastream_name, field_key, opts)
    
    html_options = opts.fetch(:html_options,{})  #keys.include?(:html_options) ? opts[:html_options] : {}

    body = ""
    
    field_values.each_with_index do |current_value, z|
      base_id = generate_base_id(field_name, current_value, field_values, opts)
 
      body << "<#{container_tag_type.to_s} class=\"editable-container field\" id=\"#{base_id}-container\">"
				delete_link= field_key_specific_delete_link(field_name,z,resource.pid,image_tag("/images/remove.png",:border=>0), current_value)
        body << "<span class=\"editable-text text\" id=\"#{base_id}-text\">#{h(current_value)}</span>"
        html_options.merge!({:class=>"editable-edit edit", 'data-datastream-name' => datastream_name, :rel => field_name,:id=>base_id})
        inputtag = text_field_tag get_name(datastream_name, field_name, z), h(current_value), html_options
        body << inputtag
        body << delete_link unless z == 0
      body << "</#{container_tag_type}>"
    end
    result = field_selectors_for(datastream_name, field_key)
    if opts.fetch(:multiple, true)
      result << content_tag(:ol, body.html_safe, :rel=>field_name)
    else
      result << body.html_safe
    end
    
    result
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
    
    height_text = opts[:height].nil? ? "" : "height: #{opts[:height]}"
    
    body = ""

    field_values.each_with_index do |current_value, z|
      base_id = generate_base_id(field_name, current_value, field_values, opts)
      name = "asset[#{datastream_name}][#{field_name}][#{z}]"
      processed_field_value = sanitize( RedCloth.new(current_value, [:sanitize_html]).to_html)
      
      body << "<#{container_tag_type.to_s} class=\"field_value textile-container field\" id=\"#{base_id}-container\">"
        # Not sure why there is we're not allowing the for the first textile to be deleted, but this was in the original helper.
        body << "<a href=\"\" title=\"Delete '#{sanitize(current_value)}'\" class=\"destructive field\">Delete</a>" unless z == 0
        body << "<div class=\"textile-text text\" id=\"#{base_id}-text\">#{processed_field_value}</div>"
        body << "<input class=\"textile-edit edit\" id=\"#{base_id}\" data-datastream-name=\"#{datastream_name}\" rel=\"#{field_name}\" name=\"#{name}\" value=\"#{sanitize(current_value)}\"/>"
        body << "<textarea class=\"textarea-edit edit\" id=\"#{base_id}\" data-datastream-name=\"#{datastream_name}\" rel=\"#{field_name}\" name=\"#{name}\" style=\"#{height_text}\">#{sanitize(current_value)}</textarea>"
      body << "</#{container_tag_type}>"
    end
    
    result = field_selectors_for(datastream_name, field_key)
    
    if opts.fetch(:multiple, true)
      result << content_tag(:ol, body.html_safe, :rel=>field_name)
    else
      result << body.html_safe
    end
    
    result
  end

  # Expects :choices option.  Option tags for the select are generated from the :choices option using Rails "options_for_select":http://apidock.com/rails/ActionView/Helpers/FormOptionsHelper/options_for_select helper
  # If no :choices option is provided, returns a regular fedora_text_field
  def fedora_select(resource, datastream_name, field_key, opts={})
    if opts[:choices].nil?
      result = fedora_text_field(resource, datastream_name, field_key, opts)
    else
      choices = opts[:choices]
      field_name = field_name_for(field_key)
      field_values = get_values_from_datastream(resource, datastream_name, field_key, opts)
      
      body = ""
      z = 0
      base_id = generate_base_id(field_name, field_values.first, field_values, opts.merge({:multiple=>false}))
      name = "asset[#{datastream_name}][#{field_name}][#{z}]"

      body << "<select name=\"#{name}\" id=\"#{field_name}\" class=\"metadata-dd select-edit\" rel=\"#{field_name}\">"
        body << options_for_select(choices, field_values)
      body << "</select>"
      
      result = field_selectors_for(datastream_name, field_key)
      result << body.html_safe
    end
    result
  end
  

  private
  def field_key_specific_delete_link(field_key, index, asset_id, text, current_value)
	   if field_key.match /^subject_\d+_topic$/
        delete_link = link_to text, subject_topic_path(:asset_id=>asset_id,:index=>index,:content_type=>@content_type), :method=>"delete", :class=>"destructive field", :title=>"Delete #{h(current_value)}"
    elsif field_key.match /^grant_number/
      delete_link = link_to text, grant_number_path(:asset_id=>asset_id,:index=>index,:content_type=>@content_type), :method=>"delete", :class=>"destructive field", :title=>"Delete #{h(current_value)}"
		elsif field_key == 'rights'
     delete_link = link_to text, multi_field_path(:asset_id=>asset_id,:index=>index,:content_type=>@content_type, :fields=>":rights", :datastream_name=>"descMetadata"), :method=>"delete", :class=>"destructive field", :title=>"Delete #{h(current_value)}"
		elsif field_key == 'see_also'
     delete_link = link_to text, multi_field_path(:asset_id=>asset_id,:index=>index,:content_type=>@content_type, :fields=>":see_also", :datastream_name=>"descMetadata"), :method=>"delete", :class=>"destructive field", :title=>"Delete #{h(current_value)}"
	elsif field_key.match /^web_related_item_location_primary_display$/
     delete_link = link_to text, multi_field_path(:asset_id=>asset_id,:index=>index,:content_type=>@content_type, :fields=>":web_related_item, :location, :primary_display", :datastream_name=>"descMetadata"), :method=>"delete", :class=>"destructive field", :title=>"Delete #{h(current_value)}"
	elsif field_key.match /^physical_description_extent$/
     delete_link = link_to text, multi_field_path(:asset_id=>asset_id,:index=>index,:content_type=>@content_type, :fields=>":physical_description, :extent", :datastream_name=>"descMetadata"), :method=>"delete", :class=>"destructive field", :title=>"Delete #{h(current_value)}"
	elsif field_key.match /^subject_temporal$/
     delete_link = link_to text, multi_field_path(:asset_id=>asset_id,:index=>index,:content_type=>@content_type, :fields=>":subject, :temporal", :datastream_name=>"descMetadata"), :method=>"delete", :class=>"destructive field", :title=>"Delete #{h(current_value)}"
  elsif field_key.match /^subject_geographic$/
     delete_link = link_to text, multi_field_path(:asset_id=>asset_id,:index=>index,:content_type=>@content_type, :fields=>":subject, :geographic", :datastream_name=>"descMetadata"), :method=>"delete", :class=>"destructive field", :title=>"Delete #{h(current_value)}"
	  else
	     delete_link = "<a href=\"\" title=\"Delete '#{h(current_value)}'\" class=\"destructive field\" src=\"/images/remove.png\">Delete</a>"
    end

    return delete_link
  end

  def get_field_info_and_container_tag(resource, datastream_name, field_key, opts)
    field_name = field_name_for(field_key)
    field_values = get_values_from_datastream(resource, datastream_name, field_key, opts)
    if opts.fetch(:multiple, true)
      container_tag_type = :li
    else
      field_values = [field_values.first]
      container_tag_type = :span
    end
    return field_name, field_values, container_tag_type
  end

  def get_name(datastream_name, field_name, index)
      name = "asset[#{datastream_name}][#{field_name}][#{index}]"
  end
end
