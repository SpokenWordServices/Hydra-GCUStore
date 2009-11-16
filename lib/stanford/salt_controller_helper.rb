require "stanford/ead_descriptor"
# Stanford SolrHelper is a controller layer mixin. It is in the controller scope: request params, session etc.
# 
# NOTE: Be careful when creating variables here as they may be overriding something that already exists.
# The ActionController docs: http://api.rubyonrails.org/classes/ActionController/Base.html
#
# Override these methods in your own controller for customizations:
# 
# class HomeController < ActionController::Base
#   
#   include Stanford::SolrHelper
#   
#   def solr_search_params
#     super.merge :per_page=>10
#   end
#   
# end
#
module Stanford::SaltControllerHelper
  
  def find_folder_siblings(document=@document)
    folder_search_params = {}
    if document[:series_facet]
      folder_search_params[:phrases] = [{:series_facet => document[:series_facet].first}]
      if document[:box_facet]
        folder_search_params[:phrases] << {:box_facet => document[:box_facet].first}
        if document[:folder_facet]
          folder_search_params[:phrases] << {:folder_facet => document[:folder_facet].first}
        end
      end
    end

    @folder_siblings = Blacklight.solr.find folder_search_params
  end
  
  def retrieve_descriptor
    # We should be grabbing this from the collection_facet param, but there's only one collection so its hard-coded.
    #collection_id = params[:collection_facet]
    collection_id = "sc0340"
    @descriptor = Stanford::EadDescriptor.retrieve( collection_id )
  end
end