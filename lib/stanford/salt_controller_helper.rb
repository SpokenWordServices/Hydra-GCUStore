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
  
  # Returns a list of datastreams for download.
  # Uses user's roles and "mime_type" value in submitted params to decide what to return.
  def downloadables(fedora_object=@fedora_object)
    if editor? 
      if params["mime_type"] == "all"
        result = fedora_object.datastreams
      else
        result = Hash[]
        fedora_object.datastreams.each_pair do |dsid,ds|
         if ds.attributes["mimeType"].include?("pdf") || ds.label.include?("_TEXT.xml") || ds.label.include?("_METS.xml")
           result[dsid] = ds
         end  
        end
      end
    else
      result = Hash[]
      fedora_object.datastreams.each_pair do |dsid,ds|
         if ds.attributes["mimeType"].include?("pdf")
           result[dsid] = ds
         end  
       end
    end 
    return result    
  end
  
  def retrieve_descriptor
    # We should be grabbing this from the collection_facet param, but there's only one collection so its hard-coded.
    #collection_id = params[:collection_facet]
    collection_id = "sc0340"
    @descriptor = Stanford::EadDescriptor.retrieve( collection_id )
  end
end