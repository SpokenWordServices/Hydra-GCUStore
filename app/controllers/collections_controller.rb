class CollectionsController < CatalogController
  
  before_filter :retrieve_descriptor, :only =>[:show]
  
  # get search results from the solr index
  def index
      @response = get_search_results
      @filters = params[:f] || []
    respond_to do |format|
      format.html { save_current_search_params }
      format.rss  { render :layout => false }
    end
=begin
    rescue RSolr::RequestError
      logger.error("Unparseable search error: #{params.inspect}" ) 
      flash[:notice] = "Sorry, I don't understand your search." 
      redirect_to :action => 'index', :q => nil , :f => nil
    rescue 
      logger.error("Unknown error: #{params.inspect}" ) 
      flash[:notice] = "Sorry, you've encountered an error. Try a different search." 
      redirect_to :action => 'index', :q => nil , :f => nil
=end
  end
  
  def show
      @response = get_search_results(:collection_facet => "e-a-feigenbaum-collection")
      params[:f] ||= Hash[]
      params[:f].merge!("collection_facet" => ["e-a-feigenbaum-collection"])
      @filters = params[:f] || []
      #@filters["collection_facet"][] = "e-a-feigenbaum-collection"
    respond_to do |format|
      format.html { save_current_search_params }
      format.rss  { render :layout => false }
    end
=begin
    rescue RSolr::RequestError
      logger.error("Unparseable search error: #{params.inspect}" ) 
      flash[:notice] = "Sorry, I don't understand your search." 
      redirect_to :action => 'index', :q => nil , :f => nil
    rescue 
      logger.error("Unknown error: #{params.inspect}" ) 
      flash[:notice] = "Sorry, you've encountered an error. Try a different search." 
      redirect_to :action => 'index', :q => nil , :f => nil
=end
  end
  
end
