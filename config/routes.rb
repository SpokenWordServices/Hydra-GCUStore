ActionController::Routing::Routes.draw do |map|  


  # overwriting blacklight /catalog routes with /resources
  map.root :controller => 'catalog', :action => 'index'
  map.resources(:catalog,
    :as => 'resources',
    :only => [:index, :show, :update],
    # /catalog/:id/image <- for ajax cover requests
    # /catalog/:id/status
    # /catalog/:id/availability
    :member=>{:image=>:get, :status=>:get, :availability=>:get, :librarian_view=>:get},
    # /catalog/map
    :collection => {:map => :get, :opensearch=>:get, :citation=>:get, :email=>:get, :sms=>:get, :endnote=>:get, :send_email_record=>:post}
  )

  map.resources :subjects

  # Load Blacklight's routes and add edit_catalog named route
  Blacklight::Routes.build map
  map.edit_catalog 'resources/:id/edit', :controller=>:catalog, :action=>:edit
  
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
  map.download_datastream_content 'assets/:asset_id/:download_id', :controller=>:downloads, :action=>:index, :conditions => {:method => :get}
  #map.download_datastream_content maps this #http://localhost:3000/assets/hull:3058/content to #http://localhost:3000/assets/hull:3058/downloads?download_id=content
end
