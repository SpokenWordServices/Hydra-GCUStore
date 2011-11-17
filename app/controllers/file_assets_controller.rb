class FileAssetsController < ApplicationController
  include Hydra::FileAssets
  include FileAssetsControllerExtra

  def datastream
    if params[:datastream] 
      af_base = ActiveFedora::Base.load_instance(params[:id])
      the_model = ActiveFedora::ContentModel.known_models_for( af_base ).first
      @object = the_model.load_instance(params[:id])
      if @object && @object.datastreams.keys.include?(params[:datastream])
        render :xml => @object.datastreams[params[:datastream]].content
        return
      end
    end
    render :text => "Unable to load datastream"
  end

end
