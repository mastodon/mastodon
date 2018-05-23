module OmniAuth
  module Strategies
    # The Developer strategy is a very simple strategy that can be used as a
    # placeholder in your application until a different authentication strategy
    # is swapped in. It has zero security and should *never* be used in a
    # production setting.
    #
    # ## Usage
    #
    # To use the Developer strategy, all you need to do is put it in like any
    # other strategy:
    #
    # @example Basic Usage
    #
    #   use OmniAuth::Builder do
    #     provider :developer
    #   end
    #
    # @example Custom Fields
    #
    #   use OmniAuth::Builder do
    #     provider :developer,
    #       :fields => [:first_name, :last_name],
    #       :uid_field => :last_name
    #   end
    #
    # This will create a strategy that, when the user visits `/auth/developer`
    # they will be presented a form that prompts for (by default) their name
    # and email address. The auth hash will be populated with these fields and
    # the `uid` will simply be set to the provided email.
    class Developer
      include OmniAuth::Strategy

      option :fields, %i[name email]
      option :uid_field, :email

      def request_phase
        form = OmniAuth::Form.new(:title => 'User Info', :url => callback_path)
        options.fields.each do |field|
          form.text_field field.to_s.capitalize.tr('_', ' '), field.to_s
        end
        form.button 'Sign In'
        form.to_response
      end

      uid do
        request.params[options.uid_field.to_s]
      end

      info do
        options.fields.inject({}) do |hash, field|
          hash[field] = request.params[field.to_s]
          hash
        end
      end
    end
  end
end
