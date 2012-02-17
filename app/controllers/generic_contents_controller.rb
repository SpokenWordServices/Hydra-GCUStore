class GenericContentsController < ApplicationController
  
  include MediaShelf::ActiveFedoraHelper
  include Hull::AssetsControllerHelper
  include HullAccessControlEnforcement
  
  before_filter :enforce_access_controls
  before_filter :require_solr
  
  def new
    @generic_content = GenericContent.new()
  end
  
  def create
	  @generic_content = GenericContent.new(params[:generic_content])
    update_set_membership(@generic_content)
    @generic_content.apply_depositor_metadata_properties(current_user.login, current_user.email)
		@generic_content.apply_base_metadata
    
    if @generic_content.save
    	flash[:notice] = "Created #{@generic_content.title} with pid #{@generic_content.pid}.."
    else
      flash[:error] = "Failed to create a Generic Content object!"
    end
    # Dump back into Blacklight-derived edit view (catalog_path) 
    # instead of (Rails-style) redirecting to GenericContentsController.edit via generic_contents_path(@generic_content)
    redirect_to edit_catalog_path(@generic_content)
  end
  
end
