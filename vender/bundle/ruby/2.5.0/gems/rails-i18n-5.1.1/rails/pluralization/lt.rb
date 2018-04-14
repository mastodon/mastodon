module RailsI18n
  module Pluralization
    module Lithuanian
      def self.rule
        lambda do |n|
          n ||= 0
          mod10 = n % 10
          mod100 = n % 100

          if mod10 == 1 && !(11..19).to_a.include?(mod100)
            :one
          elsif (2..9).to_a.include?(mod10) && !(11..19).to_a.include?(mod100)
            :few
          else
            :other
          end
        end
      end
    end
  end
end

{ :lt => {
    :'i18n' => {
      :plural => {
        :keys => [:one, :few, :other],
        :rule => RailsI18n::Pluralization::Lithuanian.rule }}}}