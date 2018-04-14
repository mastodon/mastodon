module RailsI18n
  module Pluralization
    module Manx
      def self.rule
        lambda do |n|
          n ||= 0
          if [1, 2].include?(n % 10) || n % 20 == 0
            :one
          else
            :other
          end
        end
      end
    end
  end
end

{ :gv => {
    :'i18n' => {
      :plural => {
        :keys => [:one, :other],
        :rule => RailsI18n::Pluralization::Manx.rule }}}}