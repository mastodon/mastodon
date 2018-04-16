# encoding: utf-8

module RailsI18n
  module Transliteration
    module Ukrainian
      class << self
        def rule
          lambda do |string|
            next '' unless string

            string.gsub(/./) do |char|
              # Regexp.last_match is local to the thread and method scope
              # of the method that did the pattern match.
              @pre_match, @post_match = $`, $'

              case char
              when 'Ж'
                lookahead_upcase 'ZH'
              when 'Х'
                lookahead_upcase 'KH'
              when 'Ц'
                lookahead_upcase 'TS'
              when 'Ч'
                lookahead_upcase 'CH'
              when 'Ш'
                lookahead_upcase 'SH'
              when 'Щ'
                lookahead_upcase 'SHCH'
              when 'г'
                behind =~ /[зЗ]/ ? 'gh' : 'h'
              when 'Г'
                behind =~ /[зЗ]/ ? lookahead_upcase('GH') : 'H'
              when 'є'
                letter?(behind) ? 'ie' : 'ye'
              when 'Є'
                letter?(behind) ? lookahead_upcase('IE') : lookahead_upcase('YE')
              when 'ї'
                letter?(behind) ? 'i' : 'yi'
              when 'Ї'
                letter?(behind) ? 'I' : lookahead_upcase('YI')
              when 'й'
                letter?(behind) ? 'i' : 'y'
              when 'Й'
                letter?(behind) ? 'I' : 'Y'
              when 'ю'
                letter?(behind) ? 'iu' : 'yu'
              when 'Ю'
                letter?(behind) ? lookahead_upcase('IU') : lookahead_upcase('YU')
              when 'я'
                letter?(behind) ? 'ia' : 'ya'
              when 'Я'
                letter?(behind) ? lookahead_upcase('IA') : lookahead_upcase('YA')
              when "'"
                # remove apostrophe inside a word
                letter?(behind) && letter?(ahead) ? '' : "'"
              else
                straight_lookup[char] || char
              end
            end
          end
        end

        private

        if RUBY_VERSION < '1.9'
          # two bytes will be enough for Cyrillic
          class_eval <<-END, __FILE__, __LINE__ + 1
            def behind
              tail = @pre_match && @pre_match[-2..-1]
              tail && tail.split(//).last
            end

            def ahead
              @post_match && @post_match[0..1].split(//).first
            end
          END
        else
          class_eval <<-END, __FILE__, __LINE__ + 1
            def behind
              @pre_match && @pre_match[-1]
            end

            def ahead
              @post_match && @post_match[0]
            end
          END
        end

        def downcased?(symbol)
          symbol =~ downcased_regexp
        end

        def downcased_regexp
          @downcased_regexp ||= /[а-яґєії]/
        end

        # apostrophe can be inside a word
        def letter?(symbol)
          symbol =~ letter_regexp
        end

        def letter_regexp
          @letter_regexp ||= /[а-яґєіїА-ЯҐЄІЇ'’]/
        end

        def lookahead_upcase(word)
          downcased?(ahead) ? word.capitalize : word.upcase
        end

        def straight_lookup
          @straight_lookup ||= {
            'а'=>'a','б'=>'b','в'=>'v','ґ'=>'g','д'=>'d','е'=>'e','ж'=>'zh',
            'з'=>'z','и'=>'y','і'=>'i','к'=>'k','л'=>'l','м'=>'m','н'=>'n','о'=>'o',
            'п'=>'p','р'=>'r','с'=>'s','т'=>'t','у'=>'u','ф'=>'f','х'=>'kh','ц'=>'ts',
            'ч'=>'ch','ш'=>'sh','щ'=>'shch','ь'=>'','’'=>'',
            'А'=>'A','Б'=>'B','В'=>'V','Ґ'=>'G','Д'=>'D','Е'=>'E',
            'З'=>'Z','И'=>'Y','І'=>'I','К'=>'K','Л'=>'L','М'=>'M','Н'=>'N','О'=>'O',
            'П'=>'P','Р'=>'R','С'=>'S','Т'=>'T','У'=>'U','Ф'=>'F','Ь'=>''
          }
        end
      end
    end
  end
end

{ :uk => {
    :i18n => {
      :transliterate => {
        :rule => RailsI18n::Transliteration::Ukrainian.rule }}}}