module RailsI18n
  module Pluralization
    module ScottishGaelic
      def self.rule
        lambda do |n|
          if n == 1 || n == 11
            :one
          elsif n == 2 || n == 12
            :two
          elsif ((3..10).to_a + (13..19).to_a).include?(n)
            :few
          else
            :other
          end
        end
      end
    end
  end
end

{ :gd => {
    :'i18n' => {
      :plural => {
        :keys => [:one, :two, :few, :other],
        :rule => RailsI18n::Pluralization::ScottishGaelic.rule }}}}