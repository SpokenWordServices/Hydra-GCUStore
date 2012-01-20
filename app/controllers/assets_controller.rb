class AssetsController < ApplicationController
  include Hydra::Assets
  include Hull::AssetsControllerHelper

	before_filter :check_valid_for_delete, :only => :destroy


 def destroy
    af = ActiveFedora::Base.load_instance(params[:id])
    the_model = ActiveFedora::ContentModel.known_models_for( af ).first
    unless the_model.nil?
      af = the_model.load_instance(params[:id])
      assets = af.destroy_child_assets
    end
    af.delete
    msg = "Deleted #{params[:id]}"
    msg.concat(" and associated file_asset(s): #{assets.join(", ")}") unless assets.empty?
    flash[:notice]= msg
    redirect_to url_for(:action => 'index', :controller => "catalog", :q => nil , :f => nil)
  end
end


private
def check_valid_for_delete
	af = ActiveFedora::Base.load_instance_from_solr(params[:id])
  the_model = ActiveFedora::ContentModel.known_models_for( af ).first
  unless the_model.nil?
      af = the_model.load_instance_from_solr(params[:id])
			if !(af.queue_membership == [:qa] || af.queue_membership == [:proto])
				msg = "#{params[:id]} cannot be deleted because is has been published.  Please contact the Repository adminstrator."
				flash[:notice]= msg
				redirect_to url_for(:action => 'show', :controller => "catalog", id => params[:id])
			end      
  end
end
