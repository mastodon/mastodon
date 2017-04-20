require 'rails_helper'

RSpec.describe Setting, type: :model do
  describe '.version' do
    version_file = Rails.root.join('.version')

    it "returns the version from filesystem #{version_file} when present" do
      version = 'foo'
      expect(File).to receive(:read).with(version_file).and_return version
      expect(File).to receive(:exist?).with(version_file).and_return true
      expect(described_class.version).to eq 'foo'
    end

    it 'reads from git tags if version file is missing' do
      version = "bar\n"
      expect(described_class).to receive(:`).and_return version
      expect(described_class.version).to eq 'bar'
    end

    it 'returns nil if version file and git executable are missing' do
      expect(File).to receive(:exist?).with(version_file).and_return false
      expect(described_class).to receive(:system).and_return false
      expect(described_class.version).to be_nil
    end
  end
end
