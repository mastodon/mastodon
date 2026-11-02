# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sidekiq::Config do
  let(:config_path) { Rails.root.join('config', 'sidekiq.yml') }
  let(:config) { YAML.load(ERB.new(File.read(config_path)).result, aliases: true) }
  let(:schedule) { config[:scheduler][:schedule] || {} }

  it 'contains valid worker classes' do
    schedule.each do |name, config|
      class_name = config['class']
      next unless class_name

      expect { Object.const_get(class_name) }
        .to_not raise_error, "Sidekiq job '#{name}' references an undefined class: #{class_name}"
    end
  end
end
