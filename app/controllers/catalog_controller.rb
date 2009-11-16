class CatalogController
  
  include Stanford::SaltControllerHelper
  
  #before_filter :, :only=>:show
  
  def show_with_find_folder_siblings
    show_without_find_folder_siblings
    find_folder_siblings
  end
  
  #alias_method_chain :show, :find_folder_siblings
  alias_method :show_without_find_folder_siblings, :show
  alias_method :show, :show_with_find_folder_siblings
  

  
end