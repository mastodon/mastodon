require 'spec_helper_integration'
require 'generators/doorkeeper/install_generator'

describe 'Doorkeeper::InstallGenerator' do
  include GeneratorSpec::TestCase

  tests Doorkeeper::InstallGenerator
  destination ::File.expand_path('../tmp/dummy', __FILE__)

  describe 'after running the generator' do
    before :each do
      prepare_destination
      FileUtils.mkdir(::File.expand_path('config', Pathname(destination_root)))
      FileUtils.mkdir(::File.expand_path('db', Pathname(destination_root)))
      FileUtils.copy_file(::File.expand_path('../templates/routes.rb', __FILE__), ::File.expand_path('config/routes.rb', Pathname.new(destination_root)))
      run_generator
    end

    it 'creates an initializer file' do
      assert_file 'config/initializers/doorkeeper.rb'
    end

    it 'copies the locale file' do
      assert_file 'config/locales/doorkeeper.en.yml'
    end

    it 'adds sample route' do
      assert_file 'config/routes.rb', /use_doorkeeper/
    end
  end
end
