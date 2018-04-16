# Used as "default" pluralization rule

module RailsI18n
  module Pluralization
    module OneOther
      def self.rule
        lambda { |n| n == 1 ? :one : :other }
      end

      def self.with_locale(locale)
        { locale => {
            :'i18n' => {
              :plural => {
                :keys => [:one, :other],
                :rule => rule }}}}
      end
    end
  end
end