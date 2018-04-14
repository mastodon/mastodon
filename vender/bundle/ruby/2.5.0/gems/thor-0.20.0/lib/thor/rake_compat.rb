require "rake"
require "rake/dsl_definition"

class Thor
  # Adds a compatibility layer to your Thor classes which allows you to use
  # rake package tasks. For example, to use rspec rake tasks, one can do:
  #
  #   require 'thor/rake_compat'
  #   require 'rspec/core/rake_task'
  #
  #   class Default < Thor
  #     include Thor::RakeCompat
  #
  #     RSpec::Core::RakeTask.new(:spec) do |t|
  #       t.spec_opts = ['--options', './.rspec']
  #       t.spec_files = FileList['spec/**/*_spec.rb']
  #     end
  #   end
  #
  module RakeCompat
    include Rake::DSL if defined?(Rake::DSL)

    def self.rake_classes
      @rake_classes ||= []
    end

    def self.included(base)
      # Hack. Make rakefile point to invoker, so rdoc task is generated properly.
      rakefile = File.basename(caller[0].match(/(.*):\d+/)[1])
      Rake.application.instance_variable_set(:@rakefile, rakefile)
      rake_classes << base
    end
  end
end

# override task on (main), for compatibility with Rake 0.9
instance_eval do
  alias rake_namespace namespace

  def task(*)
    task = super

    if klass = Thor::RakeCompat.rake_classes.last # rubocop:disable AssignmentInCondition
      non_namespaced_name = task.name.split(":").last

      description = non_namespaced_name
      description << task.arg_names.map { |n| n.to_s.upcase }.join(" ")
      description.strip!

      klass.desc description, Rake.application.last_description || non_namespaced_name
      Rake.application.last_description = nil
      klass.send :define_method, non_namespaced_name do |*args|
        Rake::Task[task.name.to_sym].invoke(*args)
      end
    end

    task
  end

  def namespace(name)
    if klass = Thor::RakeCompat.rake_classes.last # rubocop:disable AssignmentInCondition
      const_name = Thor::Util.camel_case(name.to_s).to_sym
      klass.const_set(const_name, Class.new(Thor))
      new_klass = klass.const_get(const_name)
      Thor::RakeCompat.rake_classes << new_klass
    end

    super
    Thor::RakeCompat.rake_classes.pop
  end
end
