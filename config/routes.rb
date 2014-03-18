SpeakerinnenListe::Application.routes.draw do

  namespace :admin do
    resources :tags, :except => [:new, :create]
    resources :categories
    resources :profiles do
      resources :medialinks
      member do
        post "publish"
        post "unpublish"
      end
    end
    root to: 'dashboard#index'
  end

  scope "(:locale)", :locale => /en|de/ do

    devise_for :profiles, controllers: {omniauth_callbacks: "omniauth_callbacks"}

    get 'topics/:topic', to: 'profiles#index', as: :topic

    match 'search' => 'search#search'

    get  'contact' => 'contact#new',    :as => 'contact'
    post 'contact' => 'contact#create', :as => 'contact'

    match 'impressum' => 'pages#impressum'
    match 'about' => 'pages#about'
    match 'links' => 'pages#links'
    match 'faq' => 'pages#faq'
    match 'press' => 'pages#press'

    get '/', to: 'pages#home', as: :root

    resources :categories, :only => :show

    resources :profiles, :except => [:new, :create] do
      resources :medialinks
      get  'contact' => 'contact#new',    :as => 'contact', :on => :member
      post 'contact' => 'contact#create', :as => 'contact', :on => :member
    end

    devise_scope :profile do
      get 'sign_up' => 'devise/registrations#new'
    end

    #get 'sign_up' => 'profiles#new'
    constraints(:host => /^(speakerinnen-liste.herokuapp.com|speakerinnen.org)$/) do
      root :to => redirect("http://www.speakerinnen.org")
      # match '/*path', :to => redirect {|params| "http://www.example.com/#{params[:path]}"}
    end
  end
end
