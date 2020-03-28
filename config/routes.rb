Rails.application.routes.draw do
  resources :thermostats, only: [] do
    resources :readings, only: [ :create, :show ], param: :number
  end
end
