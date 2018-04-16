class CustomAuthorizationsController < ::ApplicationController
  %w(index show new create edit update destroy).each do |action|
    define_method action do
      render nothing: true
    end
  end
end
