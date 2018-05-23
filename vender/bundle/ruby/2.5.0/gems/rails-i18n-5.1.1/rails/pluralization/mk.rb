module RailsI18n
  module Pluralization
    module Macedonian
      def self.rule
        lambda do |n|
          n ||= 0
          if n % 10 == 1 && n != 11
            :one
          else
            :other
          end
        end
      end
    end
  end
end

{ :mk => {
    :'i18n' => {
      :plural => {
        :keys => [:one, :other],
        :rule => RailsI18n::Pluralization::Macedonian.rule }}}}