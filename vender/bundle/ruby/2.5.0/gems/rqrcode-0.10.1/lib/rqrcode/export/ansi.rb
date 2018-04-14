module RQRCode
  module Export
    module ANSI
      ##
      # Returns a string of the QR code as
      # characters writen with ANSI background set.
      # 
      # Options: 
      # light: Foreground ("\033[47m")
      # dark: Background ANSI code. ("\033[47m")
      # fill_character: The written character. ('  ')
      # quiet_zone_size: (4)
      #
      def as_ansi(options={})
        options = {
          light: "\033[47m",
          dark: "\033[40m",
          fill_character: '  ',
          quiet_zone_size: 4
        }.merge(options)

        normal = "\033[m"
        light = options.fetch(:light)
        dark = options.fetch(:dark)
        fill_character = options.fetch(:fill_character)
        quiet_zone_size = options.fetch(:quiet_zone_size)

        output = ''

        @modules.each_index do |c|

          # start row with quiet zone
          row = light + fill_character * quiet_zone_size
          previous_dark = false

          @modules.each_index do |r|
            if is_dark(c, r)
              # dark
              if previous_dark != true
                row << dark
                previous_dark = true
              end
              row << fill_character
            else
              # light
              if previous_dark != false
                row << light
                previous_dark = false
              end
              row << fill_character
            end
          end

          # add quiet zone
          if previous_dark != false
            row << light
          end
          row << fill_character * quiet_zone_size

          # always end with reset and newline
          row << normal + "\n"

          output << row
        end

        # count the row width so we can add quiet zone rows
        width = output.each_line.first.scan(fill_character).length

        quiet_row = light + fill_character * width + normal + "\n"
        quiet_rows = quiet_row * quiet_zone_size

        return quiet_rows + output + quiet_rows
      end
    end
  end
end

RQRCode::QRCode.send :include, RQRCode::Export::ANSI
