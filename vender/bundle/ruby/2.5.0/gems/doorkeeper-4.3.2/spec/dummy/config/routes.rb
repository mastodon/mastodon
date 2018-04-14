Rails.application.routes.draw do
  use_doorkeeper
  use_doorkeeper scope: 'scope'

  scope 'inner_space' do
    use_doorkeeper scope: 'scope' do
      controllers authorizations: 'custom_authorizations',
                  tokens: 'custom_authorizations',
                  applications: 'custom_authorizations',
                  token_info: 'custom_authorizations'

      as authorizations: 'custom_auth',
         tokens: 'custom_token',
         token_info: 'custom_token_info'
    end
  end

  scope 'space' do
    use_doorkeeper do
      controllers authorizations: 'custom_authorizations',
                  tokens: 'custom_authorizations',
                  applications: 'custom_authorizations',
                  token_info: 'custom_authorizations'

      as authorizations: 'custom_auth',
         tokens: 'custom_token',
         token_info: 'custom_token_info'
    end
  end

  scope 'outer_space' do
    use_doorkeeper do
      controllers authorizations: 'custom_authorizations',
                  tokens: 'custom_authorizations',
                  token_info: 'custom_authorizations'

      as authorizations: 'custom_auth',
         tokens: 'custom_token',
         token_info: 'custom_token_info'

      skip_controllers :tokens, :applications, :token_info
    end
  end

  get 'metal.json' => 'metal#index'

  get '/callback', to: 'home#callback'
  get '/sign_in',  to: 'home#sign_in'
  resources :semi_protected_resources
  resources :full_protected_resources
  root to: 'home#index'
end
