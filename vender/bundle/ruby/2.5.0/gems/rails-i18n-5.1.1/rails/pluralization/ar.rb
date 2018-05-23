module RailsI18n
  module Pluralization
    module Arabic
      def self.rule
        lambda do |n|
          n ||= 0
          mod100 = n % 100

          if n == 0
            :zero
          elsif n == 1
            :one
          elsif n == 2
            :two
          elsif (3..10).to_a.include?(mod100)
            :few
          elsif (11..99).to_a.include?(mod100)
            :many
          else
            :other
          end
        end
      end
    end
  end
end

{ :ar => {
    :'i18n' => {
      :plural => {
        :keys => [:zero, :one, :two, :few, :many, :other],
        :rule => RailsI18n::Pluralization::Arabic.rule }}}}