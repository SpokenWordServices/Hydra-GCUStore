class CatalogController 
  
  before_filter :retrieve_descriptor, :only =>[:index, :show]

end