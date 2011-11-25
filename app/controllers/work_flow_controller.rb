class WorkFlowController < ApplicationController
  include Blacklight::SolrHelper
  include Hydra::RepositoryController
  include Hydra::AssetsControllerHelper
  include ReleaseProcessHelper
	include HullAccessControlEnforcement
    
  before_filter :require_solr
  before_filter :enforce_permissions, :only=>[:new] 

  def new
  end

  def update
    document = load_document_from_params
    if document.change_queue_membership params[:workflow_step].to_sym
      document.save
      if params[:workflow_step].to_sym == :publish
				flash[:notice] = "Successfully published #{document.pid} to the Repository."
			else      
				flash[:notice] = "Successfully added #{document.pid} to #{params[:workflow_step].to_s} queue."
			end
    else
      flash[:error] = "Errors encountered adding #{document.pid} to #{params[:workflow_step].to_s} queue: #{document.errors.join("; ")}."
    end
    redirect_to :action=>:edit, :controller=>:catalog
  end

	protected
		def enforce_permissions
			enforce_create_permissions
		end
end
