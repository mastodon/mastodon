Rails.application.routes.draw do
  mount Subscription::Engine => "/subscription"
end
