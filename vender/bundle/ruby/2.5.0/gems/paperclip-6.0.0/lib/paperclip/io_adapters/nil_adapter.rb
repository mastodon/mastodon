module Paperclip
  class NilAdapter < AbstractAdapter
    def self.register
      Paperclip.io_adapters.register self do |target|
        target.nil? || ((Paperclip::Attachment === target) && !target.present?)
      end
    end

    def initialize(_target, _options = {}); end

    def original_filename
      ""
    end

    def content_type
      ""
    end

    def size
      0
    end

    def nil?
      true
    end

    def read(*_args)
      nil
    end

    def eof?
      true
    end
  end
end

Paperclip::NilAdapter.register
