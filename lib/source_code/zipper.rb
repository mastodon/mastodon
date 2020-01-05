# frozen_string_literal: true

require 'zip'

module SourceCode
  class Zipper
    def self.create
      zip_filename = Rails.root.join('public', 'source.zip')
      FileUtils.rm_f(zip_filename)
      Zip::File.open(zip_filename, Zip::File::CREATE) do |zipfile|
        Dir.glob('**/*', base: Rails.root) do |filename|
          next if filename.match?(/.env.*|tmp|public|\.bundle|vendor|log|node_modules|config\/deploy|config\/.*\.yml/)

          zipfile.add(filename, Rails.root.join(filename))
        end
      end
    end
  end
end
