# frozen_string_literal: true

module Paperclip
  class WaveformTranscoder < Paperclip::Processor
    def make
      return @file unless options[:style] == :original

      basename = File.basename(@file.path)
      dest     = TempfileFactory.new.generate("#{basename}.json")

      begin
        Paperclip.run('audiowaveform', '-i :source -o :dest --pixels-per-second 20 -b 8', source: File.expand_path(@file.path), dest: File.expand_path(dest.path))

        data = Oj.load(File.read(File.expand_path(dest.path)))
        max  = data['data'].max

        data['data'].map! { |x| (x.to_f / max).round(2) }

        attachment.instance.waveform = Oj.dump(data)
      rescue Terrapin::CommandNotFoundError => e
        raise Paperclip::Errors::CommandNotFoundError.new('Could not run the `audiowaveform` command. Please install audiowaveform')
      ensure
        begin
          dest.unlink
        rescue Errno::ENOENT
        end
      end

      @file
    end
  end
end
