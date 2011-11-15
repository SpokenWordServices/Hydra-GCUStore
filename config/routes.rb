Hull::Application.routes.draw do
  Blacklight.add_routes(self)
  HydraHead.add_routes(self)

  root :to => "catalog#index"

  devise_for :users

  
  match 'assets/:id/datastreams/:datastream' =>'file_assets#show', :as=>'datastream_content' 
  match 'assets/:asset_id/:download_id' => 'downloads#index', :as=>'download_datastream_content'

  match 'work_flow/new' => 'work_flow#new', :as=>'workflow_new'
  match 'work_flow/:content_type/:id/:workflow_step' => 'work_flow#update', :as=>'change_queue', :via=>:put

  resources :multi_field
	match 'multi_field/:content_type/:asset_id/:index' =>'multi_field#destroy', :via => :delete


  resources :catalog, :path=>'resources', :as=>'resources'
  resources :grant_numbers
  
  resources :generic_contents

  # resources :catalog, :only=>[:index, :show, :update], :as=>'resources' do
  # end
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

  # map.resources :subjects

  
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
end
