# frozen_string_literal: true

require 'rails_helper'

Fabrication.manager.load_definitions if Fabrication.manager.empty?

Fabrication.manager.schematics.map(&:first).each do |factory_name|
  describe "The #{factory_name} factory" do
    it 'is valid' do
      factory = Fabricate(factory_name)
      expect(factory).to be_valid
    end
  end
end
