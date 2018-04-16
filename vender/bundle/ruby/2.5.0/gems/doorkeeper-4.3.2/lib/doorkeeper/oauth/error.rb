module Doorkeeper
  module OAuth
    Error = Struct.new(:name, :state) do
      def description
        I18n.translate(
          name,
          scope: %i[doorkeeper errors messages],
          default: :server_error
        )
      end
    end
  end
end
