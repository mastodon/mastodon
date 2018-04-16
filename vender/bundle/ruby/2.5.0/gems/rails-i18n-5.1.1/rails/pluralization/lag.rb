module RailsI18n
  module Pluralization
    module Langi
      def self.rule
        lambda do |n|
          n ||= 0
          if n == 0
            :zero
          elsif n > 0 && n < 2
            :one
          else
            :other
          end
        end
      end
    end
  end
end

{ :lag => {
    :'i18n' => {
      :plural => {
        :keys => [:zero, :one, :other],
        :rule => RailsI18n::Pluralization::Langi.rule }}}}