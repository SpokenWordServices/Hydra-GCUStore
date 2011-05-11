require "inline_editable_metadata_helper"
require "block_helpers"
require "vendor/plugins/hydra_repository/app/helpers/hydra_fedora_metadata_helper.rb"

module HydraFedoraMetadataHelper
  # Overwritten to provide more flexibility in the output of text_fields
  # also using rails form helpers
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
        delete_link = link_to '-', subject_path(:asset_id=>resource.pid,:index=>z,:content_type=>@content_type), :method=>"delete", :class=>"destructive field"
        #body << "<a href=\"\" title=\"Delete '#{h(current_value)}'\" class=\"destructive field\">Delete</a>" unless z == 0
        body << "<span class=\"editable-text text\" id=\"#{base_id}-text\">#{h(current_value)}</span>"
        html_options.merge!({:class=>"editable-edit edit", 'data-datastream-name' => datastream_name, :rel => field_name})
        inputtag = text_field_tag name, h(current_value), html_options
        body << inputtag
        body << delete_link
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
  
end
