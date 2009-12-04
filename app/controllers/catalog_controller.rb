require 'mediashelf/active_fedora_helper'
class CatalogController
  
  include Stanford::SaltControllerHelper
  include MediaShelf::ActiveFedoraHelper
  
  before_filter :require_solr, :require_fedora, :only=>[:show, :edit]
  before_filter :enforce_viewing_context_for_show_requests, :only=>:show
  before_filter :enforce_edit_permissions, :only=>:edit
  
  def edit
    @document_fedora = Document.load_instance(params[:id])
    #fedora_object = ActiveFedora::Base.load_instance(params[:id])
    #params[:action] = "edit"
    @downloadables = downloadables( @document_fedora )
    session[:viewing_context] = "edit"
    show_with_customizations
    render :action=>:show
  end
  
  def show_with_customizations
    show_without_customizations
    find_folder_siblings
    #facets_for_lookup = {:fields=>['title_facet', 'technology_facet', 'person_facet']}
    params = {:qt=>"dismax",:q=>"*:*",:rows=>"0",:facet=>"true", :facets=>{:fields=>Blacklight.config[:facet][:field_names]}}
    @facet_lookup = Blacklight.solr.find params
  end
  
  # trigger show_with_customizations when show is called
  # This has the same effect as the (deprecated) alias_method_chain :show, :find_folder_siblings
  alias_method :show_without_customizations, :show
  alias_method :show, :show_with_customizations
  
  private
  
  # If someone hits the show action while their session's viewing_context is in edit mode, 
  # this will redirect them to the edit action.
  # If they do not have sufficient privileges to edit documents, it will silently switch their session to browse mode.
  def enforce_viewing_context_for_show_requests    
    if params[:viewing_context] == "browse"
      session[:viewing_context] = params[:viewing_context]
    elsif session[:viewing_context] == "edit"
      if editor?
        redirect_to :action=>:edit
      else
        session[:viewing_context] = "browse"
        #flash[:message] = "You do not have sufficient privileges to edit this document."
      end
    end
  end
  
  def enforce_edit_permissions
    if !editor?
      session[:viewing_context] = "browse"
      flash[:message] = "You do not have sufficient privileges to edit this document."
      redirect_to :action=>:show
    end
  end
  
  def get_search_results(extra_controller_params={})
    _search_params = self.solr_search_params(extra_controller_params)
    index = _search_params[:qt] == 'fulltext' ? :fulltext : :default
    Blacklight.solr(index).find(_search_params)
  end
  
end