ActionController::Routing::Routes.draw do |map|
  #map.root :controller => 'collections', :action=>'index'
  map.resources :collections 
end