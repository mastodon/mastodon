module Paperclip
  class EmptyStringAdapter < AbstractAdapter
    def self.register
      Paperclip.io_adapters.register self do |target|
        target.is_a?(String) && target.empty?
      end
    end

    def nil?
      false
    end

    def assignment?
      false
    end
  end
end

Paperclip::EmptyStringAdapter.register
