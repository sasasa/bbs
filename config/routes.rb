ActionController::Routing::Routes.draw do |map|
  map.root :controller => "categories", :action => "index"

  map.with_options(:protocol => "https") do |https|
    https.login '/login', :controller => 'sessions', :action => 'new'
    https.auth '/auth', :controller => 'sessions', :action => 'create'
    https.mobile_auth '/mobile_auth', :controller => 'sessions', :action => 'mobile_create'

    https.signup '/signup', :controller => 'users', :action => 'new'
    https.register '/register', :controller => 'users', :action => 'create'

    https.activate '/activate/:activation_code', :controller => 'users',
    :action => 'activate', :activation_code => nil
  end

  map.resources :categories do |category|
    category.resources :questions,
                         :new => { :preview => [:post, :get] } do |question|
      question.resources :answers,
                         :member => { :replay_edit => :get, :replay_update => :put, :replay_preview => [:put, :get] },
                         :new => { :preview => [:post, :get] }
    end
  end
  map.resources :users, :member => { :suspend => :put, :unsuspend => :put, :purge => :delete },
                        :collection => { :new_login=>:get,:create_login=>[:post, :get] }
  map.resource :session, :only => [:new, :create, :destroy, :show],
                        :collection => { :mobile_create=>:post }

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
