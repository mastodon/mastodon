# encoding: utf-8
module Paperclip
  class FilenameCleaner
    def initialize(invalid_character_regex)
      @invalid_character_regex = invalid_character_regex
    end

    def call(filename)
      if @invalid_character_regex
        filename.gsub(@invalid_character_regex, "_")
      else
        filename
      end
    end
  end
end
