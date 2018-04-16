# Used in Akan, Amharic, Bihari, Filipino, guw, Hindi, Lingala, Malagasy,
# Northen Sotho, Tachelhit, Tagalog, Tigrinya, Walloon.

module RailsI18n
  module Pluralization
    module OneWithZeroOther
      def self.rule
        lambda { |n| n == 0 || n == 1 ? :one : :other }
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
