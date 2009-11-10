class CatalogController 
  
  helper :salt
  before_filter :retrieve_descriptor, :only =>[:index, :show]
  
  private
  
  def retrieve_descriptor
    # We should be grabbing this from the collection_facet param, but there's only one collection so its hard-coded.
    #collection_id = params[:collection_facet]
    collection_id = "sc0340"
    @descriptor = Descriptor.retrieve( collection_id )
  end

end