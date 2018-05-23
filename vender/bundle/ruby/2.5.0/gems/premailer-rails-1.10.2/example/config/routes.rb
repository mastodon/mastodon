Rails.application.routes.draw do
  root to: redirect('rails/mailers/example_mailer/test_message')
end
