# frozen_string_literal: true

namespace :yaml do
  desc 'Lint YAML ERB files'
  task lint: :environment do
    errors = []
    Dir.glob('config/*.yml').each do |file|
      begin
        YAML.load(ERB.new(File.read(file)).result, aliases: true)
      rescue => e
        errors << "Error in #{file}: #{e.message}"
      end
    end

    if errors.any?
      puts errors.join("\n")
      exit 1
    else
      puts 'All YAML files parsed successfully'
    end
  end
end
