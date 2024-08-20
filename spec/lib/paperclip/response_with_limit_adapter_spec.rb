# frozen_string_literal: true

require 'rails_helper'

describe Paperclip::ResponseWithLimitAdapter do
  subject { described_class.new(response_with_limit) }

  before { stub_request(:get, url).to_return(headers: headers, body: body) }

  let(:response_with_limit) { ResponseWithLimit.new(response, 50.kilobytes) }
  let(:response) { Request.new(:get, url).perform(&:itself) }
  let(:url) { 'https://example.com/dir/foo.png' }
  let(:headers) { nil }
  let(:body) { attachment_fixture('600x400.jpeg').binmode.read }

  it 'writes temporary file' do
    expect(subject.tempfile.read).to eq body
    expect(subject.size).to eq body.bytesize
  end

  context 'with Content-Disposition header' do
    let(:headers) { { 'Content-Disposition' => 'attachment; filename="bar.png"' } }

    it 'uses filename from header' do
      expect(subject.original_filename).to eq 'bar.png'
    end

    it 'detects MIME type from content' do
      expect(subject.content_type).to eq 'image/jpeg'
    end
  end

  context 'without Content-Disposition header' do
    it 'uses filename from path' do
      expect(subject.original_filename).to eq 'foo.png'
    end

    it 'detects MIME type from content' do
      expect(subject.content_type).to eq 'image/jpeg'
    end
  end

  context 'without filename in path' do
    let(:url) { 'https://example.com/' }

    it 'falls back to "data"' do
      expect(subject.original_filename).to eq 'data'
    end

    it 'detects MIME type from content' do
      expect(subject.content_type).to eq 'image/jpeg'
    end
  end

  context 'with very long filename' do
    let(:url) { 'https://example.com/abcdefghijklmnopqrstuvwxyz.0123456789' }

    it 'truncates the filename' do
      expect(subject.original_filename).to eq 'abcdefghijklmnopqrst.0123'
    end
  end

  context 'when response size exceeds limit' do
    context 'with Content-Length header' do
      let(:headers) { { 'Content-Length' => 5.megabytes } }

      it 'raises without reading the body' do
        allow(response).to receive(:body).and_call_original

        expect { subject }.to raise_error(Mastodon::LengthValidationError, 'Content-Length 5242880 exceeds limit of 51200')

        expect(response).to_not have_received(:body)
      end
    end

    context 'without Content-Length header' do
      let(:body) { SecureRandom.random_bytes(1.megabyte) }

      it 'raises while reading the body' do
        expect { subject }.to raise_error(Mastodon::LengthValidationError, 'Body size exceeds limit of 51200')
        expect(response.content_length).to be_nil
      end
    end
  end

  context 'when response times out' do
    it 'raises' do
      allow(response.body.connection).to receive(:readpartial).and_raise(HTTP::TimeoutError)

      expect { subject }.to raise_error(HTTP::TimeoutError)
    end
  end
end
