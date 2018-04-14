require 'spec_helper'

describe Premailer::Rails::CSSLoaders::FileSystemLoader do
  before do
    allow(Rails.configuration)
      .to receive(:assets).and_return(double(prefix: '/assets'))
    allow(Rails)
      .to receive(:root).and_return(Pathname.new('/rails_root'))
  end

  describe '#file_name' do
    subject { described_class.file_name(asset) }
    let(:relative_url_root) { nil }

    before do
      config = double(relative_url_root: relative_url_root)
      allow(Rails).to receive(:configuration).and_return(config)
    end

    context 'when relative_url_root is not set' do
      let(:asset) { '/assets/application.css' }
      it { is_expected.to eq(File.join(Rails.root, 'public/assets/application.css')) }
    end

    context 'when relative_url_root is set' do
      let(:relative_url_root) { '/foo' }
      let(:asset) { '/foo/assets/application.css' }
      it { is_expected.to eq(File.join(Rails.root, 'public/assets/application.css')) }
    end

    context 'when relative_url_root has a trailing slash' do
      let(:relative_url_root) { '/foo/' }
      let(:asset) { '/foo/assets/application.css' }
      it { is_expected.to eq(File.join(Rails.root, 'public/assets/application.css')) }
    end
  end
end
