Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users, path: "",
    path_names: {
      sign_in: "login",
      sign_out: "logout",
      registration: "signup"
    },
    controllers: {
      sessions: "users/sessions",
      registrations: "users/registrations"
    }

  # Subject Routes
  get "/subjects", to: "subjects#index"
  post "/subjects", to: "subjects#create"
  get "/subjects/:id", to: "subjects#show"
  patch "/subjects", to: "subjects#update"
  put "/subjects", to: "subjects#update"
  delete "/subjects", to: "subjects#destroy"

  # Tag Routes
  get "/tags", to: "tags#index"
  post "/tags", to: "tags#create"
  get "/tags/:id", to: "tags#show"
  patch "/tags", to: "tags#update"
  put "/tags", to: "tags#update"
  delete "/tags", to: "tags#destroy"

  # Task Routes
  get "/tasks", to: "tasks#index"
  post "/tasks", to: "tasks#create"
  get "tasks/:id", to: "tasks#show"
  patch "/tasks", to: "tasks#update"
  put "/tasks", to: "tasks#update"
  delete "/tasks", to: "tasks#destroy"

  # Workblock Routes
  get "/workblocks", to: "workblocks#index"
  get "/workblocks/:id", to: "workblocks#show"
  post "/workblocks", to: "workblocks#create"
  patch "/workblocks", to: "workblocks#update"
  put "/workblocks", to: "workblocks#update"
  delete "/workblocks", to: "workblocks#destroy"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
