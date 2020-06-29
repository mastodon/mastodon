# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Remotable do
  class Foo
    def initialize
      @attrs = {}
    end

    def [](arg)
      @attrs[arg]
    end

    def []=(arg1, arg2)
      @attrs[arg1] = arg2
    end

    def hoge=(arg); end

    def hoge_file_name; end

    def hoge_file_name=(arg); end

    def has_attribute?(arg); end

    def self.attachment_definitions
      { hoge: nil }
    end
  end

  context 'Remotable module is included' do
    before do
      class Foo
        include Remotable
        remotable_attachment :hoge, 1.kilobyte
      end
    end

    let(:attribute_name) { "#{hoge}_remote_url".to_sym }
    let(:code)           { 200 }
    let(:file)           { 'filename="foo.txt"' }
    let(:foo)            { Foo.new }
    let(:headers)        { { 'content-disposition' => file } }
    let(:hoge)           { :hoge }
    let(:url)            { 'https://google.com' }

    let(:request) do
      stub_request(:get, url)
        .to_return(status: code, headers: headers)
    end

    it 'defines a method #hoge_remote_url=' do
      expect(foo).to respond_to(:hoge_remote_url=)
    end

    it 'defines a method #reset_hoge!' do
      expect(foo).to respond_to(:reset_hoge!)
    end

    it 'defines a method #download_hoge!' do
      expect(foo).to respond_to(:download_hoge!)
    end

    describe '#hoge_remote_url=' do
      before do
        request
      end

      it 'always returns arg' do
        [nil, '', [], {}].each do |arg|
          expect(foo.hoge_remote_url = arg).to be arg
        end
      end

      context 'Addressable::URI::InvalidURIError raised' do
        it 'makes no request' do
          allow(Addressable::URI).to receive_message_chain(:parse, :normalize)
            .with(url).with(no_args).and_raise(Addressable::URI::InvalidURIError)

          foo.hoge_remote_url = url
          expect(request).not_to have_been_requested
        end
      end

      context 'scheme is neither http nor https' do
        let(:url) { 'ftp://google.com' }

        it 'makes no request' do
          foo.hoge_remote_url = url
          expect(request).not_to have_been_requested
        end
      end

      context 'parsed_url.host is empty' do
        it 'makes no request' do
          parsed_url = double(scheme: 'https', host: double(blank?: true))
          allow(Addressable::URI).to receive_message_chain(:parse, :normalize)
            .with(url).with(no_args).and_return(parsed_url)

          foo.hoge_remote_url = url
          expect(request).not_to have_been_requested
        end
      end

      context 'parsed_url.host is nil' do
        it 'makes no request' do
          parsed_url = Addressable::URI.parse('https:https://example.com/path/file.png')
          allow(Addressable::URI).to receive_message_chain(:parse, :normalize)
            .with(url).with(no_args).and_return(parsed_url)

          foo.hoge_remote_url = url
          expect(request).not_to have_been_requested
        end
      end

      context 'foo[attribute_name] == url' do
        it 'makes no request if file is saved' do
          allow(foo).to receive(:[]).with(attribute_name).and_return(url)
          allow(foo).to receive(:hoge_file_name).and_return('foo.jpg')

          foo.hoge_remote_url = url
          expect(request).not_to have_been_requested
        end

        it 'makes request if file is not saved' do
          allow(foo).to receive(:[]).with(attribute_name).and_return(url)
          allow(foo).to receive(:hoge_file_name).and_return(nil)

          foo.hoge_remote_url = url
          expect(request).to have_been_requested
        end
      end

      context "scheme is https, parsed_url.host isn't empty, and foo[attribute_name] != url" do
        it 'makes a request' do
          foo.hoge_remote_url = url
          expect(request).to have_been_requested
        end

        context 'response.code != 200' do
          let(:code) { 500 }

          it 'calls not send' do
            expect(foo).not_to receive(:public_send).with("#{hoge}=", any_args)
            expect(foo).not_to receive(:public_send).with("#{hoge}_file_name=", any_args)
            foo.hoge_remote_url = url
          end
        end

        context 'response.code == 200' do
          let(:code) { 200 }

          context 'response contains headers["content-disposition"]' do
            let(:file)      { 'filename="foo.txt"' }
            let(:headers)   { { 'content-disposition' => file } }

            it 'calls send' do
              string_io = StringIO.new('')
              extname   = '.txt'
              basename  = '0123456789abcdef'

              allow(SecureRandom).to receive(:hex).and_return(basename)
              allow(StringIO).to receive(:new).with(anything).and_return(string_io)

              expect(foo).to receive(:public_send).with("download_#{hoge}!")

              foo.hoge_remote_url = url

              expect(foo).to receive(:public_send).with("#{hoge}=", string_io)
              expect(foo).to receive(:public_send).with("#{hoge}_file_name=", basename + extname)

              foo.download_hoge!
            end
          end
        end

        context 'an error raised during the request' do
          let(:request) { stub_request(:get, url).to_raise(error_class) }

          error_classes = [
            HTTP::TimeoutError,
            HTTP::ConnectionError,
            OpenSSL::SSL::SSLError,
            Paperclip::Errors::NotIdentifiedByImageMagickError,
            Addressable::URI::InvalidURIError,
          ]

          error_classes.each do |error_class|
            let(:error_class) { error_class }

            it 'calls Rails.logger.debug' do
              expect(Rails.logger).to receive(:debug).with(/^Error fetching remote #{hoge}: /)
              foo.hoge_remote_url = url
            end
          end
        end
      end
    end
  end
end
