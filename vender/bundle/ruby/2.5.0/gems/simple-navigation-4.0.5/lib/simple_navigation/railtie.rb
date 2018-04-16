module SimpleNavigation
  class Railtie < ::Rails::Railtie
    initializer 'simple_navigation.register' do |app|
      SimpleNavigation.register
    end
  end
end
