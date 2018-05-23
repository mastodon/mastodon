# Used for Czech, Slovak.

module RailsI18n
  module Pluralization
    module WestSlavic
      def self.rule
        lambda do |n|
          if n == 1
            :one
          elsif [2, 3, 4].include?(n)
            :few
          else
            :other
          end
        end
      end

      def self.with_locale(locale)
        { locale => {
            :'i18n' => {
              :plural => {
                :keys => [:one, :few, :other],
                :rule => rule }}}}
      end
    end
  end
end
