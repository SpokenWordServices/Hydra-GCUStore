module Hydra::AccessControlsEnforcement
  #
  # Action-specific enforcement
  # Overriden to customize flash notice...
  
  # Controller "before" filter for enforcing access controls on show actions
  # @param [Hash] opts (optional, not currently used)
  def enforce_show_permissions(opts={})
    load_permissions_from_solr
    unless @permissions_solr_document['access_t'] && (@permissions_solr_document['access_t'].first == "public" || @permissions_solr_document['access_t'].first == "Public")
      if @permissions_solr_document["embargo_release_date_dt"] 
        embargo_date = Date.parse(@permissions_solr_document["embargo_release_date_dt"].split(/T/)[0])
        if embargo_date > Date.parse(Time.now.to_s)
          # check for depositor raise "#{@document["depositor_t"].first} --- #{user_key}"
          ### Assuming we're using devise and have only one authentication key
          unless current_user && user_key == @permissions_solr_document["depositor_t"].first
            flash[:notice] = "This item is under embargo.  You do not have sufficient access privileges to read this document."
            redirect_to(:action=>'index', :q=>nil, :f=>nil) and return false
          end
        end
      end
      unless reader?
        flash[:notice]= "This material is unavailable. It may have been temporarily or permanently withdrawn, or it may have restricted access. Are you logged in?"
        redirect_to(:controller => 'catalog', :action => 'index', :q => nil , :f => nil) and return false
      end
    end
  end  
end
