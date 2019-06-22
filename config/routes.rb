Rails.application.routes.draw do

  float_regex = '[+-]?[0-9]*\.?[0-9]*'
  root 'static_pages#home'

  get 'sessions/new'
  get '/home', to: 'static_pages#home'
  get '/about', to: 'static_pages#about'

  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get '/events/all', to: 'events#index', as: 'all_events'
  get '/events/my', to: 'events#my_events_index', as: 'my_events'
  get '/events/attending', to: 'events#attending_events_index', as: 'attending_events'
  get '/events/show/:id', to: 'events#show', as: 'event_show'
  get '/events/:id/edit', to: 'events#edit', as: 'edit_event'
  get '/newevent', to: 'events#new'
  get '/events/search', to: 'events#search'
  get '/events/closest/:lat/:lng/:offset/(:other)', to: 'events#closest_events', as: 'closest_events', constraints: { lat: float_regex, lng: float_regex, offset: float_regex}
  patch '/events/:id', to: 'events#update', as: 'update_event'
  delete '/events/:id', to: 'events#delete', as: 'delete_event'
  post '/newevent', to: 'events#create'
  put '/events/attend/:id', to: 'events#attend_event', as: 'event_attend'
  put '/events/unattend/:id', to: 'events#unattend_event', as: 'event_unattend'

  resources :users
  # resources :events
end
