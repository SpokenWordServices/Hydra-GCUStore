module SaltHelper

  
  def async_load_tag( url, tag )
    javascript_tag do 
      "window._token='#{form_authenticity_token}'" 
      "async_load('#{url}', '#{tag}');"
    end
  end
  
  def link_to_multifacet( name, args={} )
    facet_params = {}
    options = {}
    args.each_pair do |k,v|
      if k == :options
        options = v
      else
        facet_params[:f] ||= {}
        facet_params[:f][k] ||= []
        v = v.instance_of?(Array) ? v.first : v
        facet_params[:f][k].push(v)
      end
    end

    link_to(name, catalog_index_path(facet_params), options)
  end
  
  def ead_title( ead_description=@descriptor )
    ead_description.xpath("//archdesc[@level=\"collection\"]/did/unittitle").first.content
  end
  
  def ead_folder_title(series, box, folder, ead_description=@descriptor) 
    if folder.to_s.match(/^[0-9]*:/)
      return folder
    else
      series_id = series == "eaf7000" ? "Accession 1986-052>" : series.to_s
      folder_id = folder.to_s.gsub("Folder ", "")
      box_id = box.to_s.gsub("Box ", "")
      #puts "Series id: " + series_id + "; Box id: " + box_id + "; Folder id: " + folder_id
      xpath_query = "//dsc[@type=\"in-depth\"]/c01[did/unittitle=\"#{series_id}\"]/c02/c03/did[container[@type=\"box\"]=#{box_id} and container[@type=\"folder\"]=#{folder_id}]/unittitle"
      #puts xpath_query
      xpath_result = ead_description.xpath( xpath_query ).first
      if xpath_result.nil?
        #return "Series id: " + series_id + "; Box id: " + box_id + "; Folder id: " + folder_id
        return "#{folder_id}: Folder #{folder_id}"
      else
        return folder_id + ": " + ead_description.xpath( xpath_query ).first.content
      end
    end
  end
  
  
  def display_for_ead_node( node_name , ead_description=@descriptor ) 
    xpath_query = "//archdesc[@level=\"collection\"]/#{node_name}"
    response = ""
    response << "<dt> #{ead_description.xpath( xpath_query + "/head" ).first.content} </dt>"
    response << "<dd> #{ead_description.xpath( xpath_query + "/p" ).first.content} </dd>"
    if node_name == "controlaccess"
      response << "<ul>"
      ead_description.xpath( xpath_query + "/*[@source]" ).each do |subject|
        response << "<li>[#{subject.attribute("source")}]  #{subject.content}</li>"
      end
    end
    return response
  end
  
  def grouped_result_count(response, facet_name=nil, facet_value=nil)
    if facet_name && facet_value
      facet = response.facets.detect {|f| f.name == facet_name}
      facet_item = facet.items.detect {|i| i.value == facet_value} if facet
      count = facet_item ? facet_item.hits : 0
    else
      count = response.docs.total
    end
    pluralize(count, 'document')
  end
  
  def grouping_facet
    fields = Hash[sort_fields]
    case h(params[:sort])
    when fields['date -']
      'year_facet'
    when fields['date +']
      'year_facet'
    when fields['document type']
      'medium_t'
    when fields['location']
      'series_facet'
    else
      nil
    end
  end
  
  def document_fedora_show_html_title
    @document.datastreams["descMetadata"].title_values.first
  end
  
end