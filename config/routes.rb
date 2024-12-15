Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  root "sessions#new"  # Define a root path (e.g., a home or welcome page)

  # Session routes
  # Session routes
  get    'login',          to: 'sessions#new',         as: 'login'           # Login form
  get    'recovery',       to: 'sessions#recovery',    as: 'recovery'        # Account Recovery form
  get    'code',           to: 'sessions#code',        as: 'code'            # Recovery code entry
  post 'recovery_code',    to: 'sessions#recovery_code', as: 'recovery_code' # Check email form
  post   'verify',         to: 'sessions#verify',      as: 'verify'          # Verify recovery code
  post   'login',          to: 'sessions#create',      as: 'sessions'        # Process login
  delete 'logout',         to: 'sessions#destroy',     as: 'logout'          # Log out
  get    'signup',         to: 'users#new',            as: 'signup'          # Signup form
  post   'signup',         to: 'users#create'                                # Process signup


  get    'world',  to: 'worlds#index', as:'worlds'          # List of User worlds
  post   'world',  to: 'worlds#create', as:'create_world'   # Generate new Game ID and redirect to world#new (character form)
  delete 'world',  to: 'worlds#destroy', as:'remove_world'  # Removes a world ID from user profile
  get    'new_world',  to: 'worlds#new', as:'character'     # --Needs to be Updated later-- Will open new game server
  get    'roles', to: 'worlds#user_roles', as:'role'
  get    'landing', to: 'squares#landing', as: 'landing'
  post 'pay_shards', to: 'squares#pay_shards', as: 'pay_shards'

  get    'settings', to: 'settings#show', as: 'settings'
  patch  'settings', to: 'settings#update'

  get 'world/:id/start', to: 'worlds#start_game', as: 'start_game'
  resources :worlds, only: [:index, :new, :create, :destroy]
  resources :worlds do
    member do
      post 'pay_shards'
      get :generate_square_code
      post 'restart'
      post 'award_treasure_shards'
    end
  end
  resources :characters do
    post :update_shards, on: :member
    post 'save_coordinates', on: :member
  end


  # TMP ROUTE so I can go straight to minigame to test behavior
  get 'matching_game', to: 'matching_game#index', as: 'matching_game'
  post '/flip', to: 'matching_game#flip', as: 'flip', defaults: { format: :json }

  post 'coordinates', to: 'characters#save_coordinates'
  post '/generate_square_code', to: 'worlds#generate_square_code'

  resources :invitations, only: [:create] do
    member do
      post 'accept'
      post 'decline'
    end
  end

  resources :characters, only: [:new, :create]

  get 'worlds/join/:user_world_id', to: 'worlds#join', as: 'join_world_form'
  post 'worlds/join', to: 'worlds#join_existing', as: 'join_world'

  resources :squares do
    member do
      post :activate_square
      post :pay_shards
      post :validate_movement
    end
    collection do
      get :generate_square_code
    end
  end
end
