installers = {
  "Angular": :angular,
  "Elm": :elm,
  "React": :react,
  "Vue": :vue,
  "Erb": :erb,
  "Coffee": :coffee,
  "Typescript": :typescript,
  "Stimulus": :stimulus
}.freeze

dependencies = {
  "Angular": [:typescript]
}

namespace :webpacker do
  namespace :install do
    installers.each do |name, task_name|
      desc "Install everything needed for #{name}"
      task task_name => ["webpacker:verify_install"] do
        template = File.expand_path("../install/#{task_name}.rb", __dir__)
        base_path =
          if Rails::VERSION::MAJOR >= 5
            "#{RbConfig.ruby} ./bin/rails app:template"
          else
            "#{RbConfig.ruby} ./bin/rake rails:template"
          end

        dependencies[name] ||= []
        dependencies[name].each do |dependency|
          dependency_template = File.expand_path("../install/#{dependency}.rb", __dir__)
          system "#{base_path} LOCATION=#{dependency_template}"
        end

        exec "#{base_path} LOCATION=#{template}"
      end
    end
  end
end
