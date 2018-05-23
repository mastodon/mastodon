module Bootsnap
  module_function

  def bundler?
    # Bundler environment variable
    ['BUNDLE_BIN_PATH', 'BUNDLE_GEMFILE'].each do |current|
      return true if ENV.key?(current)
    end
    
    false
  end
end
