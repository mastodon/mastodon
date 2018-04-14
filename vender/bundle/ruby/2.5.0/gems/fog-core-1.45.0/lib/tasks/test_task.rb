require "rake"
require "rake/tasklib"

module Fog
  module Rake
    class TestTask < ::Rake::TaskLib
      def initialize
        desc "Run the mocked tests"
        task :test do
          ::Rake::Task[:mock_tests].invoke
        end

        task :mock_tests do
          tests(true)
        end

        task :real_tests do
          tests(false)
        end
      end

      def tests(mocked)
        Fog::Formatador.display_line
        start = Time.now.to_i
        threads = []
        Thread.main[:results] = []
        Fog.providers.each do |key, value|
          threads << Thread.new do
            Thread.main[:results] << {
              :provider => value,
              :success  => sh("export FOG_MOCK=#{mocked} && bundle exec shindont +#{key}")
            }
          end
        end
        threads.each(&:join)
        Fog::Formatador.display_table(Thread.main[:results].sort { |x, y| x[:provider] <=> y[:provider] })
        Fog::Formatador.display_line("[bold]FOG_MOCK=#{mocked}[/] tests completed in [bold]#{Time.now.to_i - start}[/] seconds")
        Fog::Formatador.display_line
      end
    end
  end
end
