# frozen_string_literal: true
module Rake

  # The TaskManager module is a mixin for managing tasks.
  module TaskManager
    # Track the last comment made in the Rakefile.
    attr_accessor :last_description

    def initialize # :nodoc:
      super
      @tasks = Hash.new
      @rules = Array.new
      @scope = Scope.make
      @last_description = nil
    end

    def create_rule(*args, &block) # :nodoc:
      pattern, args, deps = resolve_args(args)
      pattern = Regexp.new(Regexp.quote(pattern) + "$") if String === pattern
      @rules << [pattern, args, deps, block]
    end

    def define_task(task_class, *args, &block) # :nodoc:
      task_name, arg_names, deps = resolve_args(args)

      original_scope = @scope
      if String === task_name and
         not task_class.ancestors.include? Rake::FileTask
        task_name, *definition_scope = *(task_name.split(":").reverse)
        @scope = Scope.make(*(definition_scope + @scope.to_a))
      end

      task_name = task_class.scope_name(@scope, task_name)
      deps = [deps] unless deps.respond_to?(:to_ary)
      deps = deps.map { |d| Rake.from_pathname(d).to_s }
      task = intern(task_class, task_name)
      task.set_arg_names(arg_names) unless arg_names.empty?
      if Rake::TaskManager.record_task_metadata
        add_location(task)
        task.add_description(get_description(task))
      end
      task.enhance(deps, &block)
    ensure
      @scope = original_scope
    end

    # Lookup a task.  Return an existing task if found, otherwise
    # create a task of the current type.
    def intern(task_class, task_name)
      @tasks[task_name.to_s] ||= task_class.new(task_name, self)
    end

    # Find a matching task for +task_name+.
    def [](task_name, scopes=nil)
      task_name = task_name.to_s
      self.lookup(task_name, scopes) or
        enhance_with_matching_rule(task_name) or
        synthesize_file_task(task_name) or
        fail generate_message_for_undefined_task(task_name)
    end

    def generate_message_for_undefined_task(task_name)
      message = "Don't know how to build task '#{task_name}' (see --tasks)"
      message + generate_did_you_mean_suggestions(task_name)
    end

    def generate_did_you_mean_suggestions(task_name)
      return "" unless defined?(::DidYouMean::SpellChecker)

      suggestions = ::DidYouMean::SpellChecker.new(dictionary: @tasks.keys).correct(task_name.to_s)
      if ::DidYouMean.respond_to?(:formatter)# did_you_mean v1.2.0 or later
        ::DidYouMean.formatter.message_for(suggestions)
      elsif defined?(::DidYouMean::Formatter) # before did_you_mean v1.2.0
        ::DidYouMean::Formatter.new(suggestions).to_s
      else
        ""
      end
    end

    def synthesize_file_task(task_name) # :nodoc:
      return nil unless File.exist?(task_name)
      define_task(Rake::FileTask, task_name)
    end

    # Resolve the arguments for a task/rule.  Returns a triplet of
    # [task_name, arg_name_list, prerequisites].
    def resolve_args(args)
      if args.last.is_a?(Hash)
        deps = args.pop
        resolve_args_with_dependencies(args, deps)
      else
        resolve_args_without_dependencies(args)
      end
    end

    # Resolve task arguments for a task or rule when there are no
    # dependencies declared.
    #
    # The patterns recognized by this argument resolving function are:
    #
    #   task :t
    #   task :t, [:a]
    #
    def resolve_args_without_dependencies(args)
      task_name = args.shift
      if args.size == 1 && args.first.respond_to?(:to_ary)
        arg_names = args.first.to_ary
      else
        arg_names = args
      end
      [task_name, arg_names, []]
    end
    private :resolve_args_without_dependencies

    # Resolve task arguments for a task or rule when there are
    # dependencies declared.
    #
    # The patterns recognized by this argument resolving function are:
    #
    #   task :t => [:d]
    #   task :t, [a] => [:d]
    #
    def resolve_args_with_dependencies(args, hash) # :nodoc:
      fail "Task Argument Error" if hash.size != 1
      key, value = hash.map { |k, v| [k, v] }.first
      if args.empty?
        task_name = key
        arg_names = []
        deps = value || []
      else
        task_name = args.shift
        arg_names = key
        deps = value
      end
      deps = [deps] unless deps.respond_to?(:to_ary)
      [task_name, arg_names, deps]
    end
    private :resolve_args_with_dependencies

    # If a rule can be found that matches the task name, enhance the
    # task with the prerequisites and actions from the rule.  Set the
    # source attribute of the task appropriately for the rule.  Return
    # the enhanced task or nil of no rule was found.
    def enhance_with_matching_rule(task_name, level=0)
      fail Rake::RuleRecursionOverflowError,
        "Rule Recursion Too Deep" if level >= 16
      @rules.each do |pattern, args, extensions, block|
        if pattern && pattern.match(task_name)
          task = attempt_rule(task_name, pattern, args, extensions, block, level)
          return task if task
        end
      end
      nil
    rescue Rake::RuleRecursionOverflowError => ex
      ex.add_target(task_name)
      fail ex
    end

    # List of all defined tasks in this application.
    def tasks
      @tasks.values.sort_by { |t| t.name }
    end

    # List of all the tasks defined in the given scope (and its
    # sub-scopes).
    def tasks_in_scope(scope)
      prefix = scope.path
      tasks.select { |t|
        /^#{prefix}:/ =~ t.name
      }
    end

    # Clear all tasks in this application.
    def clear
      @tasks.clear
      @rules.clear
    end

    # Lookup a task, using scope and the scope hints in the task name.
    # This method performs straight lookups without trying to
    # synthesize file tasks or rules.  Special scope names (e.g. '^')
    # are recognized.  If no scope argument is supplied, use the
    # current scope.  Return nil if the task cannot be found.
    def lookup(task_name, initial_scope=nil)
      initial_scope ||= @scope
      task_name = task_name.to_s
      if task_name =~ /^rake:/
        scopes = Scope.make
        task_name = task_name.sub(/^rake:/, "")
      elsif task_name =~ /^(\^+)/
        scopes = initial_scope.trim($1.size)
        task_name = task_name.sub(/^(\^+)/, "")
      else
        scopes = initial_scope
      end
      lookup_in_scope(task_name, scopes)
    end

    # Lookup the task name
    def lookup_in_scope(name, scope)
      loop do
        tn = scope.path_with_task_name(name)
        task = @tasks[tn]
        return task if task
        break if scope.empty?
        scope = scope.tail
      end
      nil
    end
    private :lookup_in_scope

    # Return the list of scope names currently active in the task
    # manager.
    def current_scope
      @scope
    end

    # Evaluate the block in a nested namespace named +name+.  Create
    # an anonymous namespace if +name+ is nil.
    def in_namespace(name)
      name ||= generate_name
      @scope = Scope.new(name, @scope)
      ns = NameSpace.new(self, @scope)
      yield(ns)
      ns
    ensure
      @scope = @scope.tail
    end

    private

    # Add a location to the locations field of the given task.
    def add_location(task)
      loc = find_location
      task.locations << loc if loc
      task
    end

    # Find the location that called into the dsl layer.
    def find_location
      locations = caller
      i = 0
      while locations[i]
        return locations[i + 1] if locations[i] =~ /rake\/dsl_definition.rb/
        i += 1
      end
      nil
    end

    # Generate an anonymous namespace name.
    def generate_name
      @seed ||= 0
      @seed += 1
      "_anon_#{@seed}"
    end

    def trace_rule(level, message) # :nodoc:
      options.trace_output.puts "#{"    " * level}#{message}" if
        Rake.application.options.trace_rules
    end

    # Attempt to create a rule given the list of prerequisites.
    def attempt_rule(task_name, task_pattern, args, extensions, block, level)
      sources = make_sources(task_name, task_pattern, extensions)
      prereqs = sources.map { |source|
        trace_rule level, "Attempting Rule #{task_name} => #{source}"
        if File.exist?(source) || Rake::Task.task_defined?(source)
          trace_rule level, "(#{task_name} => #{source} ... EXIST)"
          source
        elsif parent = enhance_with_matching_rule(source, level + 1)
          trace_rule level, "(#{task_name} => #{source} ... ENHANCE)"
          parent.name
        else
          trace_rule level, "(#{task_name} => #{source} ... FAIL)"
          return nil
        end
      }
      task = FileTask.define_task(task_name, { args => prereqs }, &block)
      task.sources = prereqs
      task
    end

    # Make a list of sources from the list of file name extensions /
    # translation procs.
    def make_sources(task_name, task_pattern, extensions)
      result = extensions.map { |ext|
        case ext
        when /%/
          task_name.pathmap(ext)
        when %r{/}
          ext
        when /^\./
          source = task_name.sub(task_pattern, ext)
          source == ext ? task_name.ext(ext) : source
        when String
          ext
        when Proc, Method
          if ext.arity == 1
            ext.call(task_name)
          else
            ext.call
          end
        else
          fail "Don't know how to handle rule dependent: #{ext.inspect}"
        end
      }
      result.flatten
    end

    # Return the current description, clearing it in the process.
    def get_description(task)
      desc = @last_description
      @last_description = nil
      desc
    end

    class << self
      attr_accessor :record_task_metadata # :nodoc:
      TaskManager.record_task_metadata = false
    end
  end

end
