Rails.application.routes.draw do
  get 'sessions/new'
  root 'static_pages#home'
  get '/home', to: 'static_pages#home'
  get '/about', to: 'static_pages#about'
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get '/newevent', to: 'events#new'
  post '/newevent', to: 'events#create'
  get '/events', to: 'events#index'
  get '/events/my', to: 'events#my_events_index'
  get '/events/attending', to: 'events#attending_events_index'
  get '/events/:id/edit', to: 'events#edit'
  put '/events/attend/:id', to: 'events#attend_event', as: 'event_attend'
  put '/events/unattend/:id', to: 'events#unattend_event', as: 'event_unattend'

  resources :users
  resources :events
end
