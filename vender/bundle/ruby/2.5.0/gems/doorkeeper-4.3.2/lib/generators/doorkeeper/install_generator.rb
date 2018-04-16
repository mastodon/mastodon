class Doorkeeper::InstallGenerator < ::Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)
  desc 'Installs Doorkeeper.'

  def install
    template 'initializer.rb', 'config/initializers/doorkeeper.rb'
    copy_file File.expand_path('../../../../config/locales/en.yml', __FILE__), 'config/locales/doorkeeper.en.yml'
    route 'use_doorkeeper'
    readme 'README'
  end
end
