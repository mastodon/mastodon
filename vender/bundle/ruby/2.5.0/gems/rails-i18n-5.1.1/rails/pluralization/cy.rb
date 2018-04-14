module RailsI18n
  module Pluralization
    module Welsh
      def self.rule
        lambda do |n|
          case n
            when 0 then :zero
            when 1 then :one
            when 2 then :two
            when 3 then :few
            when 6 then :many
            else :other
          end
        end
      end
    end
  end
end

{ :cy => {
    :'i18n' => {
      :plural => {
        :keys => [:zero, :one, :two, :few, :many, :other],
        :rule => RailsI18n::Pluralization::Welsh.rule }}}}