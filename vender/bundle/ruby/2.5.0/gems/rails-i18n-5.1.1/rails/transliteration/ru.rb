# encoding: utf-8

# (c) Yaroslav Markin, Julian "julik" Tarkhanov and Co
# https://github.com/yaroslav/russian/blob/master/lib/russian/transliteration.rb

module RailsI18n
  module Transliteration
    module Russian
      class << self
        def rule
          lambda do |string|
            next '' unless string

            chars = string.scan(%r{#{multi_keys.join '|'}|\w|.})

            result = ""

            chars.each_with_index do |char, index|
              if upper.has_key?(char) && lower.has_key?(chars[index+1])
                # combined case
                result << upper[char].downcase.capitalize
              elsif upper.has_key?(char)
                result << upper[char]
              elsif lower.has_key?(char)
                result << lower[char]
              else
                result << char
              end
            end

            result
          end
        end

        private

        # use instance variables instead of constants to prevent warnings
        # on re-evaling after I18n.reload!

        def upper
          @upper ||= begin
            upper_single = {
              "Ґ"=>"G","Ё"=>"YO","Є"=>"E","Ї"=>"YI","І"=>"I",
              "А"=>"A","Б"=>"B","В"=>"V","Г"=>"G",
              "Д"=>"D","Е"=>"E","Ж"=>"ZH","З"=>"Z","И"=>"I",
              "Й"=>"Y","К"=>"K","Л"=>"L","М"=>"M","Н"=>"N",
              "О"=>"O","П"=>"P","Р"=>"R","С"=>"S","Т"=>"T",
              "У"=>"U","Ф"=>"F","Х"=>"H","Ц"=>"TS","Ч"=>"CH",
              "Ш"=>"SH","Щ"=>"SCH","Ъ"=>"'","Ы"=>"Y","Ь"=>"",
              "Э"=>"E","Ю"=>"YU","Я"=>"YA",
            }

            (upper_single.merge(upper_multi)).freeze
          end
        end

        def lower
          @lower ||= begin
            lower_single = {
              "і"=>"i","ґ"=>"g","ё"=>"yo","№"=>"#","є"=>"e",
              "ї"=>"yi","а"=>"a","б"=>"b",
              "в"=>"v","г"=>"g","д"=>"d","е"=>"e","ж"=>"zh",
              "з"=>"z","и"=>"i","й"=>"y","к"=>"k","л"=>"l",
              "м"=>"m","н"=>"n","о"=>"o","п"=>"p","р"=>"r",
              "с"=>"s","т"=>"t","у"=>"u","ф"=>"f","х"=>"h",
              "ц"=>"ts","ч"=>"ch","ш"=>"sh","щ"=>"sch","ъ"=>"'",
              "ы"=>"y","ь"=>"","э"=>"e","ю"=>"yu","я"=>"ya",
            }

            (lower_single.merge(lower_multi)).freeze
          end
        end

        def upper_multi
          @upper_multi ||= { "ЬЕ"=>"IE", "ЬЁ"=>"IE" }
        end

        def lower_multi
          @lower_multi ||= { "ье"=>"ie", "ьё"=>"ie" }
        end

        def multi_keys
          @multi_keys ||= (lower_multi.merge(upper_multi)).keys.sort_by {|s| s.length}.reverse.freeze
        end
      end
    end
  end
end

{ :ru => {
    :i18n => {
      :transliterate => {
        :rule => RailsI18n::Transliteration::Russian.rule }}}}