# frozen_string_literal: true

require 'rails_helper'

describe Server do
  describe 'accepts_link?' do
    subject { Server.new(agent).accepts_link? }

    context 'if the user agent is Mastodon older than or equal to 2.3.0' do
      let(:agent) { 'http.rb/3.0.0 (Mastodon/2.3.0; +https://example.com/)' }
      it { is_expected.to eq false }
    end

    context 'if the user agent is Mastodon newer than 2.3.0' do
      let(:agent) { 'http.rb/3.0.0 (Mastodon/2.3.1; +https://example.com/)' }
      it { is_expected.to eq true }
    end

    context 'if the user agent is unknown' do
      let(:agent) { 'http.rb/3.0.0 (NCSA_Mosaic/2.3.0; +https://example.com/)' }
      it { is_expected.to eq true }
    end
  end
end
