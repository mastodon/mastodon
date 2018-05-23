Shindo.tests("Excon support for middlewares that return canned responses") do
  the_body = "canned"

  canned_response_middleware = Class.new(Excon::Middleware::Base) do
    define_method :request_call do |params|
      params[:response] = {
        :body     => the_body,
        :headers  => {},
        :status   => 200
      }
      super(params)
    end
  end

  tests('does not mutate the canned response body').returns(the_body) do
    Excon.get(
      'http://some-host.com/some-path',
      :middlewares    => [canned_response_middleware] + Excon.defaults[:middlewares]
    ).body
  end

  tests('yields non-mutated body to response_block').returns(the_body) do
    body = ''
    response_block = lambda { |chunk, _, _| body << chunk }
    Excon.get(
      'http://some-host.com/some-path',
      :middlewares    => [canned_response_middleware] + Excon.defaults[:middlewares],
      :response_block => response_block
    )
    body
  end

end

