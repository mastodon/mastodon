# TODO: Clean up this doc and dry up the conditionals
#
# Required params:
#   plugin (e.g., webrick, unicorn, etc)
#   file (e.g. a rackup )
#
# Optional params:
# optional paramters may given as a hash
# opts may contain a bind argument
# opts may also contain before and after options
#
# In its simplest form:
# { :before => :start, :after => :stop }
#
# With lambdas, which recieve @server as an argument
# { before: lambda {|s| s.start }, after: lambda { |s| s.stop} }
#
# In both the cases above, before defaults to before(:all)
# This can be circumvented with a Hash
# { before: { :context => :start }, after: { :context => :stop } }
# or
# { before: { context: lambda { |s| s.start } }, after: { context: lambda { |s| s.stop } } }

shared_context "test server" do |plugin, file, opts = {}|
  plugin = plugin.to_sym unless plugin.is_a? Symbol
  if plugin == :unicorn && RUBY_PLATFORM == "java"
    before { skip("until unicorn supports jruby") }
  end
  abs_file = Object.send("#{plugin}_path", file)
  args = { plugin => abs_file}
  args[:bind] = opts[:bind] if opts.key? :bind


  before_hook = opts.key?(:before) && (opts[:before].is_a?(Symbol) || opts[:before].is_a?(Proc) || opts[:before].is_a?(Hash))

  if before_hook && opts[:before].is_a?(Hash)
    event = opts[:before].keys.first
    before(event) {
      @server = Excon::Test::Server.new(args)
      if opts[:before][event].is_a? Symbol
        @server.send(opts[:before][event])
      else
        opts[:before][event].call(@server)
      end
    }
  elsif
    before(:all) {
      @server = Excon::Test::Server.new(args)
      before_hook = opts.key?(:before) && (opts[:before].is_a?(Symbol) || opts[:before].is_a?(Proc) || opts[:before].is_a?(Hash))

      if before_hook
        if opts[:before].is_a? Symbol
          @server.send(opts[:before])
        else
          opts[:before].call(@server)
        end
      end
    }
  end

  after_hook = opts.key?(:after) && (opts[:after].is_a?(Symbol) || opts[:after].is_a?(Proc) || opts[:after].is_a?(Hash))

  if after_hook && opts[:after].is_a?(Hash)
      event = opts[:after].keys.first
      after(event) {
        if opts[:after][event].is_a? Symbol
          @server.send(opts[:after][event])
        else
          opts[:after][event].call(@server)
        end
      }
  elsif after_hook
    after(:all) {
      if opts[:after].is_a? Symbol
        @server.send(opts[:after])
      elsif opts[:after].is_a? Hash

      else
        opts[:after].call(@server)
      end
    }
  end
end
