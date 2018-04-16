module HttpAcceptLanguage
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      env["http_accept_language.parser"] = Parser.new(env["HTTP_ACCEPT_LANGUAGE"])
      
      def env.http_accept_language
        self["http_accept_language.parser"]
      end
      
      @app.call(env)
    end
  end
end
