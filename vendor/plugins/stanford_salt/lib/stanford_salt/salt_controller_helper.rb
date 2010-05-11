require "stanford_salt/ead_descriptor"
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
module StanfordSalt::SaltControllerHelper
  
  def find_folder_siblings(document=@document)
    if document[:series_facet] && document[:box_facet] && document[:folder_facet]
      folder_search_params = {}
      folder_search_params[:phrases] = [{:series_facet => document[:series_facet].first}]
      if document[:box_facet]
        folder_search_params[:phrases] << {:box_facet => document[:box_facet].first}
        if document[:folder_facet]
          folder_search_params[:phrases] << {:folder_facet => document[:folder_facet].first}
        end
      end
      @folder_siblings = Blacklight.solr.find folder_search_params
    else 
      @folder_siblings = nil
    end
  end
  
end