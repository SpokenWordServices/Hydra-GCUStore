require 'mediashelf/active_fedora_helper'
class CatalogController
  
  include Blacklight::CatalogHelper
  include Hydra::RepositoryController
  include Hydra::AccessControlsEnforcement
  include Hydra::FileAssetsHelper  
  
  before_filter :require_solr, :require_fedora, :only=>[:show, :edit, :index, :delete]
  
  def setup_next_document
    @next_document = (session[:search][:counter] && session[:search][:counter].to_i > 0) ? setup_document_by_counter(session[:search][:counter].to_i + 1) : nil
  end

# displays values and pagination links for a single facet field
  def facet
    # adding the following for facet_pagination with Lucene queries to avoide NPE
    @extra_controller_params ||= {:qt=>'dismax'} 
    @extra_controller_params.merge!(:q=>build_lucene_query(params[:q])) 
    @pagination = get_facet_pagination( params[:id], @extra_controller_params ) 
  end

end
