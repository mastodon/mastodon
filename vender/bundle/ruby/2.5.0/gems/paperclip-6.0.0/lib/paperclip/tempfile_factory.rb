module Paperclip
  class TempfileFactory

    def generate(name = random_name)
      @name = name
      file = Tempfile.new([basename, extension])
      file.binmode
      file
    end

    def extension
      File.extname(@name)
    end

    def basename
      Digest::MD5.hexdigest(File.basename(@name, extension))
    end

    def random_name
      SecureRandom.uuid
    end
  end
end
