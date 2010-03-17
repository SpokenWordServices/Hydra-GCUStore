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
    :qt=>:search,
    :per_page => 10,
    :facets => {:fields=>
      ["technology_facet",
        "person_facet",
        "title_facet",
        "city_facet",
        "organization_facet",
        "company_facet",
        "year_facet",
        "state_facet",
        "series_facet",
        "box_facet",
        "folder_facet"]
    }  
  }
  
  # default params for the SolrDocument.find_by_id method
  SolrDocument.default_params[:find_by_id] = {
    :qt => :document,
    :facets => {:fields=>
      ["technology_facet",
        "person_facet",
        "title_facet",
        "city_facet",
        "organization_facet",
        "company_facet",
        "year_facet",
        "state_facet",
        "series_facet",
        "box_facet",
        "folder_facet"]
      }
    }
  
  
  ##############################
  
  
  config[:default_qt] = "search"
  config[:public_qt] = "public_search"
  

  # solr field values given special treatment in the show (single result) view
  config[:show] = {
    :html_title => "title_t",
    :heading => "title_t",
    :display_type => "id"
  }

  # solr fld values given special treatment in the index (search results) view
  config[:index] = {
    :show_link => "title_facet",
    :num_per_page => 40,
    :record_display_type => "id"
  }

  # solr fields that will be treated as facets by the blacklight application
  #   The ordering of the field names is the order of the display 
  config[:facet] = {
    :field_names => [
      "collection_facet",
      "technology_facet",
      "person_facet",
      "city_facet",
      "organization_facet",
      "company_facet",
      "year_facet",
      "state_facet",
      "series_facet",
      "box_facet",
      "folder_facet",
      "donor_tags_facet",
      "archivist_tags_facet"
    ],
    :labels => {
      "collection_facet" => "Collection",
      "technology_facet" => "Technology",
      "person_facet" => "Person",
      "city_facet" => "City",
      "organization_facet" => "Organization",
      "company_facet" => "Company",
      "year_facet" => "Year",
      "state_facet" => "State",
      "series_facet" => "Series",
      "box_facet" => "Box",
      "folder_facet" => "Folder",
      "donor_tags_facet" => "Tagged by Donor",
      "archivist_tags_facet" => "Tagged by Archivist"
    }
  }

  # solr fields to be displayed in the index (search results) view
  #   The ordering of the field names is the order of the display 
  config[:index_fields] = {
    :field_names => [
      "text",
      "title_facet",
      "title_t",
      "date_t",
      "medium_t",
      "series_facet",
      "box_facet",
      "folder_facet"
    ],
    :labels => {
      "text" => "Text:",
      "title_t" => "Title:",
      "title_facet" => "Extracted Title:",
      "date_t" => "Date:",
      "medium_t" => "Document Type:",
      "series_facet" => "Series",
      "box_facet" => "Box",
      "folder_facet" => "Folder"
    }
  }

  # solr fields to be displayed in the show (single result) view
  #   The ordering of the field names is the order of the display 
  config[:show_fields] = {
    :field_names => [
      "text",
      "title_facet",
      "date_t",
      "medium_t",
      "location_t",
      "rights_t",
      "access_t"
    ],
    :labels => {
      "text" => "Text:",
      "title_facet" => "Title:",
      "date_t" => "Date:",
      "medium_t" => "Document Type:",
      "location_t" => "Location:",
      "rights_t"  => "Copyright:",
      "access_t" => "Access:"
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
  config[:search_fields] << ['Descriptions', 'search']
  config[:search_fields] << ['Descriptions and full text', 'fulltext']
  
  # "sort results by" select (pulldown)
  # label in pulldown is followed by the name of the SOLR field to sort by and
  # whether the sort is ascending or descending (it must be asc or desc
  # except in the relevancy case).
  # label is key, solr field is value
  config[:sort_fields] ||= []
  config[:sort_fields] << ['relevance', 'score desc, year_facet desc, month_facet asc, title_facet asc']
  config[:sort_fields] << ['date -', 'year_facet desc, month_facet asc, title_facet asc']
  config[:sort_fields] << ['date +', 'year_facet asc, month_facet asc, title_facet asc']
  config[:sort_fields] << ['title', 'title_facet asc']
  config[:sort_fields] << ['document type', 'medium_t asc, year_facet desc, month_facet asc, title_facet asc']
  config[:sort_fields] << ['location', 'series_facet asc, box_facet asc, folder_facet asc, year_facet desc, month_facet asc, title_facet asc']
  
  # If there are more than this many search results, no spelling ("did you 
  # mean") suggestion is offered.
  config[:spell_max] = 5
  
  # number of facets to show before adding a more link
  config[:facet_more_num] = 5
end

