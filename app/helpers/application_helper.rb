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

  # Standard display of a facet value in a list. Used in both _facets sidebar
  # partial and catalog/facet expanded list. Will output facet value name as
  # a link to add that to your restrictions, with count in parens. 
  # first arg item is a facet value item from rsolr-ext.
  # options consist of:
  # :suppress_link => true # do not make it a link, used for an already selected value for instance
  def render_facet_value(facet_solr_field, item, options ={})    
    value = ['top_level_collection_id_s'].include?(facet_solr_field) ? catalog_name(item.value) : item.value
    (link_to_unless(options[:suppress_link], value, add_facet_params_and_redirect(facet_solr_field, item.value), :class=>"facet_select label") + " " + render_facet_count(item.hits)).html_safe
  end

  # val should be a pointer to an object of the format: info:fedora/narmdemo:999
  # this method tries to find the title_display for this object in the solr index otherwise it just returns the pid (e.g narmdemo:999)
  def catalog_name (val)
    junk, pid = val.split('/')
    pid.sub!(':', '\:')
    result = Blacklight.solr.find(:q=>"id:#{pid}", :qt=>'standard')
    if result.docs 
      if result.docs.first['title_t'] 
        result.docs.first['title_t'].first 
      else
        logger.warn "#{result.docs.first['id']} does not have a title_display in solr"
        result.docs.first['id']
      end
    else 
      'Not Found'
    end
  end

end
