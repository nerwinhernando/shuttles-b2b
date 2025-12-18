Rails.application.routes.draw do
  # Main site (no subdomain)
  constraints subdomain: '' do
    root 'pages#home'
  end

  # Tenant subdomains
  constraints subdomain: /.+/ do
    devise_for :users, controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations',
      passwords: 'users/passwords'
    }
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
