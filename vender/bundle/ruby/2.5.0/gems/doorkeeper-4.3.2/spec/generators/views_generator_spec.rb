require 'spec_helper_integration'
require 'generators/doorkeeper/views_generator'

describe Doorkeeper::Generators::ViewsGenerator do
  include GeneratorSpec::TestCase

  tests Doorkeeper::Generators::ViewsGenerator
  destination File.expand_path('../tmp/dummy', __FILE__)

  before :each do
    prepare_destination
  end

  it 'create all views' do
    run_generator
    assert_file 'app/views/doorkeeper/applications/_form.html.erb'
    assert_file 'app/views/doorkeeper/applications/edit.html.erb'
    assert_file 'app/views/doorkeeper/applications/index.html.erb'
    assert_file 'app/views/doorkeeper/applications/new.html.erb'
    assert_file 'app/views/doorkeeper/applications/show.html.erb'

    assert_file 'app/views/doorkeeper/authorizations/error.html.erb'
    assert_file 'app/views/doorkeeper/authorizations/new.html.erb'

    assert_file 'app/views/doorkeeper/authorized_applications/index.html.erb'
  end
end
