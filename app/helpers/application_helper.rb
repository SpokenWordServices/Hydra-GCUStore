require 'vendor/plugins/blacklight/app/helpers/application_helper.rb'
require 'vendor/plugins/hydra_repository/app/helpers/application_helper.rb'
module ApplicationHelper
  
# For some reason, this file seems to need to exists in order for rspec to work. 
# If not, the ApplicationHelper from hydra_repository is not loaded  and (therefore) the Blacklight
# ApplicationHelper is not overridden. 

  # Change the name of your application here
  def application_name
    'Hydrangea'
  end

#   COPIED from vendor/plugins/blacklight/app/helpers/application_helper.rb
  # Used in catalog/facet action, facets.rb view, for a click
  # on a facet value. Add on the facet params to existing
  # search constraints. Remove any paginator-specific request
  # params, or other request params that should be removed
  # for a 'fresh' display. 
  # Change the action to 'index' to send them back to
  # catalog/index with their new facet choice. 
  def add_facet_params_and_redirect(field, value)
    new_params = add_facet_params(field, value)

    # Delete page, if needed. 
    new_params.delete(:page)

    # Delete :qt, if needed - added to resolve NPE errors
    new_params.delete(:qt)

    # Delete any request params from facet-specific action, needed
    # to redir to index action properly. 
    Blacklight::Solr::FacetPaginator.request_keys.values.each do |paginator_key| 
      new_params.delete(paginator_key)
    end
    new_params.delete(:id)

    # Force action to be index. 
    new_params[:action] = "index"

    new_params
  end

end
