Hull::Application.routes.draw do

  root :to => "catalog#index"

  devise_for :users

  resources :assets do
    resources :contributors
  end
  
  match 'assets/:id/datastreams/:datastream' =>'file_assets#datastream', :as=>'datastream_content' 
  match 'assets/:id/:download_id' => 'downloads#index', :as=>'download_datastream_content', :via=>:get

  match 'compound/:id' => 'compound#show', :via=>:get, :as=>'compound'
  match 'compound/:id' => 'compound#create', :as=>'compound_upload', :via=>:post
  match 'compound/:id' => 'compound#destroy', :as=>'compound_delete', :via=>:delete

  match 'work_flow/new' => 'work_flow#new', :as=>'workflow_new'
  match 'work_flow/:content_type/:id/:workflow_step' => 'work_flow#update', :as=>'change_queue', :via=>:put

  resources :multi_field
	match 'multi_field/:content_type/:asset_id/:index' =>'multi_field#destroy', :via => :delete


  resources :catalog, :path=>'resources', :as=>'resources'
  resources :grant_numbers
  match 'grant_numbers/:content_type/:asset_id/:index' => 'grant_numbers#show', :as=>'grant_number',:via => :get 
  match 'grant_numbers/:content_type/:asset_id/:index' => 'grant_numbers#destroy', :via=>:delete  

  resources :datasets
  resources :generic_contents
  resources :subjects
  match 'subjects/:content_type/:asset_id/:index' => 'contributors#show', :as=>'subject_topic', :via=>:get
  match 'subjects/:content_type/:asset_id/:index' => 'subjects#destroy', :via=>:delete
  resources :catalog, :only=>[:index, :edit, :show, :update], :as=>'resources' 

  resources :version, :only=>:index

  ## Write the Hull routes first so that they supercede the blacklight & hydra routes
  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  # map.resources(:catalog,
  #   :as => 'resources',
  #   :only => [:index, :show, :update],
  #   # /catalog/:id/image <- for ajax cover requests
  #   # /catalog/:id/status
  #   # /catalog/:id/availability
  #   :member=>{:image=>:get, :status=>:get, :availability=>:get, :librarian_view=>:get},
  #   # /catalog/map
  #   :collection => {:map => :get, :opensearch=>:get, :citation=>:get, :email=>:get, :sms=>:get, :endnote=>:get, :send_email_record=>:post}
  # )


  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'

  # Allow static pages to be routed within the app - this must be the last line in this file

  match ':action' => 'static#:action'
end
