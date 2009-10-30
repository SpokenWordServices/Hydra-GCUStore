module SaltHelper

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
  
  def retrieve_descriptor
    # We should be grabbing this from the collection_facet param, but there's only one collection so its hard-coded.
    #collection_id = params[:collection_facet]
    collection_id = "sc0340"
    @descriptor = Descriptor.retrieve( collection_id )
  end
  
  def ead_title( ead_description=@descriptor )
    ead_description.xpath("//archdesc[@level=\"collection\"]/did/unittitle").first.content
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
  
end