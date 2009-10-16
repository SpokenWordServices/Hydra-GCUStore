# You can configure Blacklight from here. 
#   
#   Blacklight.configure(:environment) do |config| end
#   
# :shared (or leave it blank) is used by all environments. 
# You can override a shared key by using that key in a particular
# environment's configuration.
# 
# If you have no configuration beyond :shared for an environment, you
# do not need to call configure() for that envirnoment.
# 
# For specific environments:
# 
#   Blacklight.configure(:test) {}
#   Blacklight.configure(:development) {}
#   Blacklight.configure(:production) {}
# 

Blacklight.configure(:shared) do |config|
  
  # default params for the SolrDocument.search method
  SolrDocument.default_params[:search] = {
    :qt=>:dismax,
    :per_page => 10,
    :facets => {:fields=>
      ["technology_facet",
        "person_facet",
        "title_facet",
        "city_facet",
        "organization_facet",
        "company_facet",
        "year_facet",
        "state_facet"]
    }  
  }
  
  # default params for the SolrDocument.find_by_id method
  SolrDocument.default_params[:find_by_id] = {:qt => :document}
  
  
  ##############################
  
  
  config[:default_qt] = "dismax"
  

  # solr field values given special treatment in the show (single result) view
  config[:show] = {
    :html_title => "id",
    :heading => "id",
    :display_type => "id"
  }

  # solr fld values given special treatment in the index (search results) view
  config[:index] = {
    :show_link => "id",
    :num_per_page => 10,
    :record_display_type => "id"
  }

  # solr fields that will be treated as facets by the blacklight application
  #   The ordering of the field names is the order of the display 
  config[:facet] = {
    :field_names => [
      "technology_facet",
      "person_facet",
      "title_facet",
      "city_facet",
      "organization_facet",
      "company_facet",
      "year_facet",
      "state_facet"
    ],
    :labels => {
      "technology_facet" => "Technology",
      "person_facet" => "Person",
      "title_facet" => "Title",
      "city_facet" => "City",
      "organization_facet" => "Organization",
      "company_facet" => "Company",
      "year_facet" => "Year",
      "state_facet" => "State"
    }
  }

  # solr fields to be displayed in the index (search results) view
  #   The ordering of the field names is the order of the display 
  config[:index_fields] = {
    :field_names => [
      "text",
      "title_facet",
      "type"
    ],
    :labels => {
      "text" => "Text:",
      "title_facet" => "Title:",
    }
  }

  # solr fields to be displayed in the show (single result) view
  #   The ordering of the field names is the order of the display 
  config[:show_fields] = {
    :field_names => [
      "text",
      "title_facet"
    ],
    :labels => {
      "text" => "Text:",
      "title_facet" => "Title:"
    }
  }

# FIXME: is this now redundant with above?
  # type of raw data in index.  Currently marcxml and marc21 are supported.
  config[:raw_storage_type] = "marc21"
  # name of solr field containing raw data
  config[:raw_storage_field] = "marc_display"

  # "fielded" search select (pulldown)
  # label in pulldown is followed by the name of a SOLR request handler as 
  # defined in solr/conf/solrconfig.xml
  config[:search_fields] ||= []
  config[:search_fields] << ['All Fields', 'dismax']
  
  # "sort results by" select (pulldown)
  # label in pulldown is followed by the name of the SOLR field to sort by and
  # whether the sort is ascending or descending (it must be asc or desc
  # except in the relevancy case).
  # label is key, solr field is value
  config[:sort_fields] ||= []
  config[:sort_fields] << ['relevance', 'score desc']
  
  # If there are more than this many search results, no spelling ("did you 
  # mean") suggestion is offered.
  config[:spell_max] = 5
end

