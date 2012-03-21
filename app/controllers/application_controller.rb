class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller
  # Adds Hydra behaviors into the application controller 
  include Hydra::Controller

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  def layout_name
   'sws'
  end



  protect_from_forgery
end
