module RailsI18n
  module Pluralization
    module CentralMoroccoTamazight
      def self.rule
        lambda do |n|
          if ([0, 1] + (11..99).to_a).include?(n)
            :one
          else
            :other
          end
        end
      end
    end
  end
end

{ :tzm => {
    :'i18n' => {
      :plural => {
        :keys => [:one, :other],
        :rule => RailsI18n::Pluralization::CentralMoroccoTamazight.rule }}}}