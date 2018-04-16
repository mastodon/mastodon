module RailsI18n
  module Pluralization
    module Colognian
      def self.rule
        lambda do |n|
          if n == 0
            :zero
          elsif n == 1
            :one
          else
            :other
          end
        end
      end
    end
  end
end

{ :ksh => {
    :'i18n' => {
      :plural => {
        :keys => [:zero, :one, :other],
        :rule => RailsI18n::Pluralization::Colognian.rule }}}}