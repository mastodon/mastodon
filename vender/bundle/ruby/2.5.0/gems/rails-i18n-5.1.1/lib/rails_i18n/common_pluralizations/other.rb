module RailsI18n
  module Pluralization
    module Other
      def self.rule
        Proc.new { :other }
      end

      def self.with_locale(locale)
        { locale => {
            :'i18n' => {
              :plural => {
                :keys => [:other],
                :rule => rule }}}}
      end
    end
  end
end
