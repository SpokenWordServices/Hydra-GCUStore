ActionController::Routing::Routes.draw do |map|
  #map.root :controller => 'collections', :action=>'index'
  map.resources :collections 
  map.resources :documents do |documents|
    documents.resources :downloads, :only=>[:index]
  end
end