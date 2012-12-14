class AssetsController < ApplicationController
  include Hydra::Assets
  include Hull::AssetsControllerHelper

 
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

