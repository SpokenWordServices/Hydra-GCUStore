# You can configure Blacklight from here. 
#   
#   Blacklight.configure(:environment) do |config| end
#   
# :shared (or leave it blank) is used by all environments. 
# You can override a shared key by using that key in a particular
# environment's configuration.
# 
# If you have no configuration beyond :shared for an environment, you
# do not need to call configure() for that environment.
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
      ["date_t",
        "title_t",
        "medium_t",
        "location_t"]
    }  
  }
  
  # default params for the SolrDocument.find_by_id method
  SolrDocument.default_params[:find_by_id] = {
    :qt => :document,
    :facets => {:fields=>
      ["date_t",
        "title_t",
        "medium_t",
        "location_t"]
      }
    }
  
  
  ##############################
  
  
  config[:default_qt] = "search"
  config[:public_qt] = "public_search"
  

  # solr field values given special treatment in the show (single result) view
  config[:show] = {
    :html_title => "title_t",
    :heading => "title_t",
    :display_type => "has_model_s"
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
      "object_type_facet",
      "person_full_name_facet",
      "mods_organization_facet",
      "topic_tag_facet",
      "language_lang_code_facet",
      "mods_journal_title_info_facet",
      "gps_facet",
      "region_facet",
      "site_facet",
      "ecosystem_facet"
      ],
    :labels => {
      "object_type_facet"=>"Type",
      "person_full_name_facet"=>"Person",
      "mods_organization_facet"=>"Organization",
      "topic_tag_facet"=>"Topic",
      "language_lang_code_facet"=>"Language",
      "mods_journal_title_info_facet"=>"Journal",
      "gps_facet"=>"GPS Coordinates",
      "region_facet"=>"Region",
      "site_facet"=>"Site",
      "ecosystem_facet"=>"Ecosystem"
    },
    :limits=> {nil=>10}
  }

  # solr fields to be displayed in the index (search results) view
  #   The ordering of the field names is the order of the display 
  config[:index_fields] = {
    :field_names => [
      "date_t",
      "title_t",
      "medium_t",
      "location_t"],
    :labels => {
      "date_t"=>"Date",
      "title_t"=>"Title",
      "medium_t"=>"Content Type",
      "location_t"=>"Location"
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
