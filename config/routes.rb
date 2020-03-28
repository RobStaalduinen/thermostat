Rails.application.routes.draw do
  resources :thermostats, only: [] do
    resources :readings, only: [ :create, :show ]
  end
end
