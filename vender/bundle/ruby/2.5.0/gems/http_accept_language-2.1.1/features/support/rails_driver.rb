require 'aruba/api'

class RailsDriver
  include Aruba::Api

  def initialize
    @aruba_io_wait_seconds = 10
    # @announce_stdout = true
    # @announce_stderr = true
    # @announce_cmd = true
    # @announce_dir = true
    # @announce_env = true
  end

  def app_name
    "foobar"
  end

  def install_gem
    if app_exists?
      cd app_name
    else
      generate_rails
      append_gemfile
    end
  end

  def app_exists?
    in_current_dir do
      File.exist?("#{app_name}/Gemfile")
    end
  end

  def bundle_exec(cmd)
    run_simple "bundle exec #{cmd}"
  end

  def generate_rails
    # install rails with as few things as possible, for speed!
    bundle_exec "rails new #{app_name} --force --skip-git --skip-active-record --skip-sprockets --skip-javascript --skip-test-unit --old-style-hash"
    cd app_name
  end

  def append_gemfile
    # Specifiy a path so cucumber will use the unreleased version of the gem
    append_to_file "Gemfile", "gem 'http_accept_language', :path => '#{gem_path}'"
  end

  def gem_path
    File.expand_path('../../../', __FILE__)
  end

  def generate_controller(name, content)
    bundle_exec "rails generate resource #{name} --force"
    write_file "app/controllers/#{name}_controller.rb", content
  end

  def request_with_http_accept_language_header(header, path)
    run_simple "curl  --retry 10 -H 'Accept-language: #{header}' #{File.join(host, path)} -o #{response}"
    run_simple "cat out.html"
  end

  def host
    "http://localhost:13000"
  end

  def with_rails_running
    start_rails
    yield
  ensure
    stop_rails
  end

  def start_rails
    bundle_exec "rails server -p 13000 -d"
  end

  def stop_rails
    in_current_dir do
      `cat tmp/pids/server.pid | xargs kill -9`
    end
  end

  def response
    File.expand_path(File.join(current_dir, 'out.html'))
  end

  def output_should_contain(expected)
    actual = File.open(response, 'r:utf-8').read
    actual.should include expected
  end

end
