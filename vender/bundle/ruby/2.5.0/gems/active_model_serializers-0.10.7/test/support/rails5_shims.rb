module Rails5Shims
  module ControllerTests
    # https://github.com/rails/rails/blob/b217354/actionpack/lib/action_controller/test_case.rb
    REQUEST_KWARGS = [:params, :headers, :session, :flash, :method, :body, :xhr].freeze

    def get(path, *args)
      fold_kwargs!(args)
      super
    end

    def post(path, *args)
      fold_kwargs!(args)
      super
    end

    def patch(path, *args)
      fold_kwargs!(args)
      super
    end

    def put(path, *args)
      fold_kwargs!(args)
      super
    end

    # Fold kwargs from test request into args
    # Band-aid for DEPRECATION WARNING
    def fold_kwargs!(args)
      hash = args && args[0]
      return unless hash.respond_to?(:key)
      Rails5Shims::ControllerTests::REQUEST_KWARGS.each do |kwarg|
        next unless hash.key?(kwarg)
        value = hash.delete(kwarg)
        if value.is_a? String
          args.insert(0, value)
        else
          hash.merge! value
        end
      end
    end

    # Uncomment for debugging where the kwargs warnings come from
    # def non_kwarg_request_warning
    #   super.tap do
    #     STDOUT.puts caller[2..3]
    #   end
    # end
  end
end
if Rails::VERSION::MAJOR < 5
  ActionController::TestCase.send :include, Rails5Shims::ControllerTests
  ActionDispatch::IntegrationTest.send :include, Rails5Shims::ControllerTests
end
