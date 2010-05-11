module ApplicationHelper
  include Stanford::SearchworksHelper
  #include Stanford::SolrHelper # this is already included by the SearchworksHelper
  include HydraHelper
  
  def application_name
    'Hydrangea (Hydra Demo App)'
  end
  
  def get_data_with_linked_label(doc, label, field_string, opts={})
   
    (opts[:default] and !doc[field_string]) ? field = opts[:default] : field = doc[field_string]
    delim = opts[:delimiter] ? opts[:delimiter] : "<br/>"
    if doc[field_string]
      text = "<dt>#{label}</dt><dd>"
      if field.respond_to?(:each)
        text += field.map do |l| 
          linked_label(l, field_string)
        end.join(delim)
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
  def link_to_document(doc, opts={:label=>Blacklight.config[:index][:show_link].to_sym, :counter => nil,:title => nil})
    label = case opts[:label]
      when Symbol
        doc.get(opts[:label])
      when String
        opts[:label]
      else
        raise 'Invalid label argument'
      end
    link_to_with_data(label, catalog_path(doc[:id]), {:method => :put, :data => {:counter => opts[:counter]},:title=>opts[:title]})
  end
end