Rails.application.routes.draw do

  root 'static_pages#home'

  get 'sessions/new'
  get '/home', to: 'static_pages#home'
  get '/about', to: 'static_pages#about'

  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get '/events/all(/:page)', to: 'events#index', :defaults => { :page => '1'}, as: 'all_events'
  get '/events/my(/:page)', to: 'events#my_events_index', :defaults => { :page => '1' }, as: 'my_events'
  get '/events/attending(/:page)', to: 'events#attending_events_index', :defaults => { :page => '1' }, as: 'attending_events'
  get '/events/show/:id', to: 'events#show', as: 'event_show'
  get '/events/:id/edit', to: 'events#edit', as: 'edit_event'
  get '/newevent', to: 'events#new'
  get '/events/search', to: 'events#search'
  delete '/events/:id', to: 'events#delete', as: 'delete_event'
  post '/newevent', to: 'events#create'
  put '/events/attend/:id', to: 'events#attend_event', as: 'event_attend'
  put '/events/unattend/:id', to: 'events#unattend_event', as: 'event_unattend'

  resources :users
  # resources :events
end
