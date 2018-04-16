require "erb"

class Thor
  module Actions
    # Copies the file from the relative source to the relative destination. If
    # the destination is not given it's assumed to be equal to the source.
    #
    # ==== Parameters
    # source<String>:: the relative path to the source root.
    # destination<String>:: the relative path to the destination root.
    # config<Hash>:: give :verbose => false to not log the status, and
    #                :mode => :preserve, to preserve the file mode from the source.

    #
    # ==== Examples
    #
    #   copy_file "README", "doc/README"
    #
    #   copy_file "doc/README"
    #
    def copy_file(source, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      destination = args.first || source
      source = File.expand_path(find_in_source_paths(source.to_s))

      create_file destination, nil, config do
        content = File.binread(source)
        content = yield(content) if block
        content
      end
      if config[:mode] == :preserve
        mode = File.stat(source).mode
        chmod(destination, mode, config)
      end
    end

    # Links the file from the relative source to the relative destination. If
    # the destination is not given it's assumed to be equal to the source.
    #
    # ==== Parameters
    # source<String>:: the relative path to the source root.
    # destination<String>:: the relative path to the destination root.
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Examples
    #
    #   link_file "README", "doc/README"
    #
    #   link_file "doc/README"
    #
    def link_file(source, *args)
      config = args.last.is_a?(Hash) ? args.pop : {}
      destination = args.first || source
      source = File.expand_path(find_in_source_paths(source.to_s))

      create_link destination, source, config
    end

    # Gets the content at the given address and places it at the given relative
    # destination. If a block is given instead of destination, the content of
    # the url is yielded and used as location.
    #
    # ==== Parameters
    # source<String>:: the address of the given content.
    # destination<String>:: the relative path to the destination root.
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Examples
    #
    #   get "http://gist.github.com/103208", "doc/README"
    #
    #   get "http://gist.github.com/103208" do |content|
    #     content.split("\n").first
    #   end
    #
    def get(source, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      destination = args.first

      if source =~ %r{^https?\://}
        require "open-uri"
      else
        source = File.expand_path(find_in_source_paths(source.to_s))
      end

      render = open(source) { |input| input.binmode.read }

      destination ||= if block_given?
        block.arity == 1 ? yield(render) : yield
      else
        File.basename(source)
      end

      create_file destination, render, config
    end

    # Gets an ERB template at the relative source, executes it and makes a copy
    # at the relative destination. If the destination is not given it's assumed
    # to be equal to the source removing .tt from the filename.
    #
    # ==== Parameters
    # source<String>:: the relative path to the source root.
    # destination<String>:: the relative path to the destination root.
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Examples
    #
    #   template "README", "doc/README"
    #
    #   template "doc/README"
    #
    def template(source, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      destination = args.first || source.sub(/#{TEMPLATE_EXTNAME}$/, "")

      source  = File.expand_path(find_in_source_paths(source.to_s))
      context = config.delete(:context) || instance_eval("binding")

      create_file destination, nil, config do
        content = CapturableERB.new(::File.binread(source), nil, "-", "@output_buffer").tap do |erb|
          erb.filename = source
        end.result(context)
        content = yield(content) if block
        content
      end
    end

    # Changes the mode of the given file or directory.
    #
    # ==== Parameters
    # mode<Integer>:: the file mode
    # path<String>:: the name of the file to change mode
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Example
    #
    #   chmod "script/server", 0755
    #
    def chmod(path, mode, config = {})
      return unless behavior == :invoke
      path = File.expand_path(path, destination_root)
      say_status :chmod, relative_to_original_destination_root(path), config.fetch(:verbose, true)
      unless options[:pretend]
        require "fileutils"
        FileUtils.chmod_R(mode, path)
      end
    end

    # Prepend text to a file. Since it depends on insert_into_file, it's reversible.
    #
    # ==== Parameters
    # path<String>:: path of the file to be changed
    # data<String>:: the data to prepend to the file, can be also given as a block.
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Example
    #
    #   prepend_to_file 'config/environments/test.rb', 'config.gem "rspec"'
    #
    #   prepend_to_file 'config/environments/test.rb' do
    #     'config.gem "rspec"'
    #   end
    #
    def prepend_to_file(path, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      config[:after] = /\A/
      insert_into_file(path, *(args << config), &block)
    end
    alias_method :prepend_file, :prepend_to_file

    # Append text to a file. Since it depends on insert_into_file, it's reversible.
    #
    # ==== Parameters
    # path<String>:: path of the file to be changed
    # data<String>:: the data to append to the file, can be also given as a block.
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Example
    #
    #   append_to_file 'config/environments/test.rb', 'config.gem "rspec"'
    #
    #   append_to_file 'config/environments/test.rb' do
    #     'config.gem "rspec"'
    #   end
    #
    def append_to_file(path, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      config[:before] = /\z/
      insert_into_file(path, *(args << config), &block)
    end
    alias_method :append_file, :append_to_file

    # Injects text right after the class definition. Since it depends on
    # insert_into_file, it's reversible.
    #
    # ==== Parameters
    # path<String>:: path of the file to be changed
    # klass<String|Class>:: the class to be manipulated
    # data<String>:: the data to append to the class, can be also given as a block.
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Examples
    #
    #   inject_into_class "app/controllers/application_controller.rb", ApplicationController, "  filter_parameter :password\n"
    #
    #   inject_into_class "app/controllers/application_controller.rb", ApplicationController do
    #     "  filter_parameter :password\n"
    #   end
    #
    def inject_into_class(path, klass, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      config[:after] = /class #{klass}\n|class #{klass} .*\n/
      insert_into_file(path, *(args << config), &block)
    end

    # Injects text right after the module definition. Since it depends on
    # insert_into_file, it's reversible.
    #
    # ==== Parameters
    # path<String>:: path of the file to be changed
    # module_name<String|Class>:: the module to be manipulated
    # data<String>:: the data to append to the class, can be also given as a block.
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Examples
    #
    #   inject_into_module "app/helpers/application_helper.rb", ApplicationHelper, "  def help; 'help'; end\n"
    #
    #   inject_into_module "app/helpers/application_helper.rb", ApplicationHelper do
    #     "  def help; 'help'; end\n"
    #   end
    #
    def inject_into_module(path, module_name, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      config[:after] = /module #{module_name}\n|module #{module_name} .*\n/
      insert_into_file(path, *(args << config), &block)
    end

    # Run a regular expression replacement on a file.
    #
    # ==== Parameters
    # path<String>:: path of the file to be changed
    # flag<Regexp|String>:: the regexp or string to be replaced
    # replacement<String>:: the replacement, can be also given as a block
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Example
    #
    #   gsub_file 'app/controllers/application_controller.rb', /#\s*(filter_parameter_logging :password)/, '\1'
    #
    #   gsub_file 'README', /rake/, :green do |match|
    #     match << " no more. Use thor!"
    #   end
    #
    def gsub_file(path, flag, *args, &block)
      return unless behavior == :invoke
      config = args.last.is_a?(Hash) ? args.pop : {}

      path = File.expand_path(path, destination_root)
      say_status :gsub, relative_to_original_destination_root(path), config.fetch(:verbose, true)

      unless options[:pretend]
        content = File.binread(path)
        content.gsub!(flag, *args, &block)
        File.open(path, "wb") { |file| file.write(content) }
      end
    end

    # Uncomment all lines matching a given regex.  It will leave the space
    # which existed before the comment hash in tact but will remove any spacing
    # between the comment hash and the beginning of the line.
    #
    # ==== Parameters
    # path<String>:: path of the file to be changed
    # flag<Regexp|String>:: the regexp or string used to decide which lines to uncomment
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Example
    #
    #   uncomment_lines 'config/initializers/session_store.rb', /active_record/
    #
    def uncomment_lines(path, flag, *args)
      flag = flag.respond_to?(:source) ? flag.source : flag

      gsub_file(path, /^(\s*)#[[:blank:]]*(.*#{flag})/, '\1\2', *args)
    end

    # Comment all lines matching a given regex.  It will leave the space
    # which existed before the beginning of the line in tact and will insert
    # a single space after the comment hash.
    #
    # ==== Parameters
    # path<String>:: path of the file to be changed
    # flag<Regexp|String>:: the regexp or string used to decide which lines to comment
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Example
    #
    #   comment_lines 'config/initializers/session_store.rb', /cookie_store/
    #
    def comment_lines(path, flag, *args)
      flag = flag.respond_to?(:source) ? flag.source : flag

      gsub_file(path, /^(\s*)([^#|\n]*#{flag})/, '\1# \2', *args)
    end

    # Removes a file at the given location.
    #
    # ==== Parameters
    # path<String>:: path of the file to be changed
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Example
    #
    #   remove_file 'README'
    #   remove_file 'app/controllers/application_controller.rb'
    #
    def remove_file(path, config = {})
      return unless behavior == :invoke
      path = File.expand_path(path, destination_root)

      say_status :remove, relative_to_original_destination_root(path), config.fetch(:verbose, true)
      if !options[:pretend] && File.exist?(path)
        require "fileutils"
        ::FileUtils.rm_rf(path)
      end
    end
    alias_method :remove_dir, :remove_file

    attr_accessor :output_buffer
    private :output_buffer, :output_buffer=

  private

    def concat(string)
      @output_buffer.concat(string)
    end

    def capture(*args)
      with_output_buffer { yield(*args) }
    end

    def with_output_buffer(buf = "".dup) #:nodoc:
      raise ArgumentError, "Buffer can not be a frozen object" if buf.frozen?
      old_buffer = output_buffer
      self.output_buffer = buf
      yield
      output_buffer
    ensure
      self.output_buffer = old_buffer
    end

    # Thor::Actions#capture depends on what kind of buffer is used in ERB.
    # Thus CapturableERB fixes ERB to use String buffer.
    class CapturableERB < ERB
      def set_eoutvar(compiler, eoutvar = "_erbout")
        compiler.put_cmd = "#{eoutvar}.concat"
        compiler.insert_cmd = "#{eoutvar}.concat"
        compiler.pre_cmd = ["#{eoutvar} = ''.dup"]
        compiler.post_cmd = [eoutvar]
      end
    end
  end
end
