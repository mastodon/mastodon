module RailsI18n
  module Pluralization
    module Maltese
      def self.rule
        lambda do |n|
          n ||= 0
          mod100 = n % 100

          if n == 1
            :one
          elsif n == 0 || (2..10).to_a.include?(mod100)
            :few
          elsif (11..19).to_a.include?(mod100)
            :many
          else
            :other
          end
        end
      end
    end
  end
end

{ :mt => {
    :'i18n' => {
      :plural => {
        :keys => [:one, :few, :many, :other],
        :rule => RailsI18n::Pluralization::Maltese.rule }}}}