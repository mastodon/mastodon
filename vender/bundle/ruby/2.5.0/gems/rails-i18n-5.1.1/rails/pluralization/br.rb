module RailsI18n
  module Pluralization
    module Breton
      def self.rule
        lambda do |n|
          n ||= 0
          mod10 = n % 10
          mod100 = n % 100

          if mod10 == 1 && ![11,71,91].include?(mod100)
            :one
          elsif mod10 == 2 && ![12,72,92].include?(mod100)
            :two
          elsif [3,4,9].include?(mod10) && !((10..19).to_a + (70..79).to_a + (90..99).to_a).include?(mod100)
            :few
          elsif n % 1000000 == 0 && n != 0
            :many
          else
            :other
          end
        end
      end
    end
  end
end

{ :br => {
    :'i18n' => {
      :plural => {
        :keys => [:one, :two, :few, :many, :other],
        :rule => RailsI18n::Pluralization::Breton.rule }}}}