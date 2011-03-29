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

  map.datastream_content 'assets/:id/datastreams/:datastream', :controller=>:file_assets, :action=>:show, :conditions => {:method => :get}
  map.download_datastream_content 'assets/:asset_id/genericContent/:download_id', :controller=>:downloads, :action=>:index, :conditions => {:method => :get}
  map.download_datastream_content 'assets/:asset_id/compoundContent/:download_id', :controller=>:downloads, :action=>:index, :conditions => {:method => :get}
  #supports both the genericContent & compoundContent calls, ie:-
  #map.download_datastream_content maps this #http://localhost:3000/assets/hull:3058/genericContent/content to #http://localhost:3000/assets/hull:3058/downloads?download_id=content
  #map.download_datastream_content maps this #http://localhost:3000/assets/hull:3058/compoundContent/content02 to #http://localhost:3000/assets/hull:3058/downloads?download_id=content02 
 
end
