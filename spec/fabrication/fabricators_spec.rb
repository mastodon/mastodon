# frozen_string_literal: true

require 'rails_helper'

Fabrication.manager.load_definitions if Fabrication.manager.empty?

Fabrication.manager.schematics.map(&:first).each do |factory_name|
  RSpec.describe "The #{factory_name} factory" do
    it 'is able to create valid records' do
      records = Fabricate.times(2, factory_name) # Create multiple of each to uncover uniqueness issues
      expect(records).to all(be_valid)
    end
  end
end
