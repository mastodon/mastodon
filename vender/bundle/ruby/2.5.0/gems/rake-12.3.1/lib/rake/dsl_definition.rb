# frozen_string_literal: true
# Rake DSL functions.
require "rake/file_utils_ext"

module Rake

  ##
  # DSL is a module that provides #task, #desc, #namespace, etc.  Use this
  # when you'd like to use rake outside the top level scope.
  #
  # For a Rakefile you run from the command line this module is automatically
  # included.

  module DSL

    #--
    # Include the FileUtils file manipulation functions in the top
    # level module, but mark them private so that they don't
    # unintentionally define methods on other objects.
    #++

    include FileUtilsExt
    private(*FileUtils.instance_methods(false))
    private(*FileUtilsExt.instance_methods(false))

    private

    # :call-seq:
    #   task task_name
    #   task task_name: dependencies
    #   task task_name, arguments => dependencies
    #
    # Declare a basic task.  The +task_name+ is always the first argument.  If
    # the task name contains a ":" it is defined in that namespace.
    #
    # The +dependencies+ may be a single task name or an Array of task names.
    # The +argument+ (a single name) or +arguments+ (an Array of names) define
    # the arguments provided to the task.
    #
    # The task, argument and dependency names may be either symbols or
    # strings.
    #
    # A task with a single dependency:
    #
    #   task clobber: %w[clean] do
    #     rm_rf "html"
    #   end
    #
    # A task with an argument and a dependency:
    #
    #   task :package, [:version] => :test do |t, args|
    #     # ...
    #   end
    #
    # To invoke this task from the command line:
    #
    #   $ rake package[1.2.3]
    #
    def task(*args, &block) # :doc:
      Rake::Task.define_task(*args, &block)
    end

    # Declare a file task.
    #
    # Example:
    #   file "config.cfg" => ["config.template"] do
    #     open("config.cfg", "w") do |outfile|
    #       open("config.template") do |infile|
    #         while line = infile.gets
    #           outfile.puts line
    #         end
    #       end
    #     end
    #  end
    #
    def file(*args, &block) # :doc:
      Rake::FileTask.define_task(*args, &block)
    end

    # Declare a file creation task.
    # (Mainly used for the directory command).
    def file_create(*args, &block)
      Rake::FileCreationTask.define_task(*args, &block)
    end

    # Declare a set of files tasks to create the given directories on
    # demand.
    #
    # Example:
    #   directory "testdata/doc"
    #
    def directory(*args, &block) # :doc:
      result = file_create(*args, &block)
      dir, _ = *Rake.application.resolve_args(args)
      dir = Rake.from_pathname(dir)
      Rake.each_dir_parent(dir) do |d|
        file_create d do |t|
          mkdir_p t.name unless File.exist?(t.name)
        end
      end
      result
    end

    # Declare a task that performs its prerequisites in
    # parallel. Multitasks does *not* guarantee that its prerequisites
    # will execute in any given order (which is obvious when you think
    # about it)
    #
    # Example:
    #   multitask deploy: %w[deploy_gem deploy_rdoc]
    #
    def multitask(*args, &block) # :doc:
      Rake::MultiTask.define_task(*args, &block)
    end

    # Create a new rake namespace and use it for evaluating the given
    # block.  Returns a NameSpace object that can be used to lookup
    # tasks defined in the namespace.
    #
    # Example:
    #
    #   ns = namespace "nested" do
    #     # the "nested:run" task
    #     task :run
    #   end
    #   task_run = ns[:run] # find :run in the given namespace.
    #
    # Tasks can also be defined in a namespace by using a ":" in the task
    # name:
    #
    #   task "nested:test" do
    #     # ...
    #   end
    #
    def namespace(name=nil, &block) # :doc:
      name = name.to_s if name.kind_of?(Symbol)
      name = name.to_str if name.respond_to?(:to_str)
      unless name.kind_of?(String) || name.nil?
        raise ArgumentError, "Expected a String or Symbol for a namespace name"
      end
      Rake.application.in_namespace(name, &block)
    end

    # Declare a rule for auto-tasks.
    #
    # Example:
    #  rule '.o' => '.c' do |t|
    #    sh 'cc', '-o', t.name, t.source
    #  end
    #
    def rule(*args, &block) # :doc:
      Rake::Task.create_rule(*args, &block)
    end

    # Describes the next rake task.  Duplicate descriptions are discarded.
    # Descriptions are shown with <code>rake -T</code> (up to the first
    # sentence) and <code>rake -D</code> (the entire description).
    #
    # Example:
    #   desc "Run the Unit Tests"
    #   task test: [:build]
    #     # ... run tests
    #   end
    #
    def desc(description) # :doc:
      Rake.application.last_description = description
    end

    # Import the partial Rakefiles +fn+.  Imported files are loaded
    # _after_ the current file is completely loaded.  This allows the
    # import statement to appear anywhere in the importing file, and yet
    # allowing the imported files to depend on objects defined in the
    # importing file.
    #
    # A common use of the import statement is to include files
    # containing dependency declarations.
    #
    # See also the --rakelibdir command line option.
    #
    # Example:
    #   import ".depend", "my_rules"
    #
    def import(*fns) # :doc:
      fns.each do |fn|
        Rake.application.add_import(fn)
      end
    end
  end
  extend FileUtilsExt
end

# Extend the main object with the DSL commands. This allows top-level
# calls to task, etc. to work from a Rakefile without polluting the
# object inheritance tree.
self.extend Rake::DSL
