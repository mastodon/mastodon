module Temple
  # @api public
  module Templates
    autoload :Tilt,  'temple/templates/tilt'
    autoload :Rails, 'temple/templates/rails'

    def self.method_missing(name, engine, options = {})
      const_get(name).create(engine, options)
    end
  end
end
