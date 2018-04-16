module RailsI18n
  module Pluralization
    module UpperSorbian
      def self.rule
        lambda do |n|
          n ||= 0
          mod100 = n % 100

          if mod100 == 1
            :one
          elsif mod100 == 2
            :two
          elsif mod100 == 3 || mod100 == 4
            :few
          else
            :other
          end
        end
      end
    end
  end
end

{ :hsb => {
    :'i18n' => {
      :plural => {
        :keys => [:one, :two, :few, :other],
        :rule => RailsI18n::Pluralization::UpperSorbian.rule }}}}
