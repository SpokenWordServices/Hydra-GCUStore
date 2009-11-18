require 'mediashelf/active_fedora_helper'
class CatalogController
  
  include Stanford::SaltControllerHelper
  include MediaShelf::ActiveFedoraHelper
  
  before_filter :require_solr, :require_fedora, :only=>[:show, :edit]
  
  def edit
    @document_fedora = Document.load_instance(params[:id])
    fedora_object = ActiveFedora::Base.load_instance(params[:id])
    #params[:action] = "edit"
    @downloadables = downloadables( fedora_object )
    show_with_customizations
    render :action=>:show
  end
  
  def show_with_customizations
    show_without_customizations
    find_folder_siblings
  end
  
  # trigger show_with_customizations when show is called
  # This has the same effect as the (deprecated) alias_method_chain :show, :find_folder_siblings
  alias_method :show_without_customizations, :show
  alias_method :show, :show_with_customizations
  

  
end