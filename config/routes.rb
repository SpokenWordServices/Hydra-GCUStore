ActionController::Routing::Routes.draw do |map|  
  
  # Load Blacklight's routes and add edit_catalog named route
  Blacklight::Routes.build map
  map.edit_catalog 'catalog/:id/edit', :controller=>:catalog, :action=>:edit
  
  #map.root :controller => 'collections', :action=>'index'
  # map.resources :assets do |assets|
  #   assets.resources :downloads, :only=>[:index]
  # end
  map.resources :get, :only=>:show  
  map.resources :webauths, :protocol => ((defined?(SSL_ENABLED) and SSL_ENABLED) ? 'https' : 'http')
  map.login "login", :controller => "webauth_sessions", :action => "new"
  map.logout "logout", :controller => "webauth_sessions", :action => "destroy"
  map.superuser 'superuser', :controller => 'user_sessions', :action => 'superuser'
end
