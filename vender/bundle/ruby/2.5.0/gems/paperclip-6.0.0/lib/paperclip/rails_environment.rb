module Paperclip
  class RailsEnvironment
    def self.get
      new.get
    end

    def get
      if rails_exists? && rails_environment_exists?
        Rails.env
      else
        nil
      end
    end

    private

    def rails_exists?
      Object.const_defined?(:Rails)
    end

    def rails_environment_exists?
      Rails.respond_to?(:env)
    end
  end
end
