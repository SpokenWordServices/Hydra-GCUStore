module ApplicationHelper
  include Stanford::SearchworksHelper
  #include Stanford::SolrHelper # this is already included by the SearchworksHelper
  include SaltHelper
  
  def application_name
    'SALT (Self Archiving Legacy Toolkit)'
  end
  
  def get_data_with_linked_label(doc, label, field_string, opts={})
   
    (opts[:default] and !doc[field_string]) ? field = opts[:default] : field = doc[field_string]
    
    if doc[field_string]
      text = "<dt>#{label}</dt><dd>"
      if field.respond_to?(:each)
        text += field.map do |l| 
          linked_label(l, field_string)
        end.join("<br/>")
      else
        text += linked_label(field, field_string)
      end
      text += "</dd>"
      text
    end
  end
  
  def linked_label(field, field_string)
    link_to(field, add_facet_params(field_string, field).merge!({"controller" => "catalog", :action=> "index"}))
  end
  
end