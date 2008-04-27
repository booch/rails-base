ActionController::Routing::Routes.draw do |map|
  map.resource :user, :controller => 'user', :member => {
    :activate => :get,
    :forgot_password => :get,
    :create_password_reset_code => :post,
    :reset_password => :get,
    :change_forgotten_password => :post
  }

  # Made suspend a put, because it is basically an update call.
  map.resources :users, :member => {
    :suspend => :put,
    :roles => :get,
    :add_roles => :post,
    :remove_roles => :delete
  }

  # XXX: This is kind of kludgy. Other ideas?
  map.resource :session, :controller => 'session', :member => {
    :logout => :get
  }

  # XXX: Not sure if we actually HAVE to have 'user/login' or if
  # 'sessions/new' will suffice, but this will make the acceptance
  # test pass.
  map.login  'user/login',  :controller => 'session', :action => :new
  map.logout 'user/logout', :controller => 'session', :action => :logout

  # XXX: Can take this out later
  map.index '/', :controller => 'index', :action => :index

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
