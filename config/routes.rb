ActionController::Routing::Routes.draw do |map|
  #map.root :controller => 'collections', :action=>'index'
  map.resources :collections 
  map.resources :documents do |documents|
    documents.resources :downloads, :only=>[:index]
  end
  map.resources :get, :only=>:show  
  map.connect 'catalog/:id/edit', :controller=>:catalog, :action=>:edit
  map.resources :webauths, :protocol => ((defined?(SSL_ENABLED) and SSL_ENABLED) ? 'https' : 'http')
  map.login "login", :controller => "webauth_sessions", :action => "new"
  map.logout "logout", :controller => "webauth_sessions", :action => "destroy"
end
