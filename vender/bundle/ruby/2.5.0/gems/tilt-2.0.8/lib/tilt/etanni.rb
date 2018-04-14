require 'tilt/template'

module Tilt
  class EtanniTemplate < Template
    def prepare
      separator = data.hash.abs
      chomp = "<<#{separator}.chomp!"
      start = "\n_out_ << #{chomp}\n"
      stop = "\n#{separator}\n"
      replacement = "#{stop}\\1#{start}"

      temp = data.strip
      temp.gsub!(/<\?r\s+(.*?)\s+\?>/m, replacement)

      @code = "_out_ = [<<#{separator}.chomp!]\n#{temp}#{stop}_out_.join"
    end

    def precompiled_template(locals)
      @code
    end

    def precompiled(locals)
      source, offset = super
      [source, offset + 1]
    end
  end
end
