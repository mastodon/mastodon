# frozen_string_literal: true

module ObfuscateFilename
  extend ActiveSupport::Concern

  class_methods do
    def obfuscate_filename(path)
      before_action do
        file = params.dig(*path)
        next if file.nil?

        file.original_filename = SecureRandom.hex(8) + File.extname(file.original_filename)
      end
    end
  end
end
