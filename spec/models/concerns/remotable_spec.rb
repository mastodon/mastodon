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

    describe '#hoge_remote_url' do
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
          parsed_url = double(scheme: 'https', host: double(empty?: true))
          allow(Addressable::URI).to receive_message_chain(:parse, :normalize)
            .with(url).with(no_args).and_return(parsed_url)

          foo.hoge_remote_url = url
          expect(request).not_to have_been_requested
        end
      end

      context 'foo[attribute_name] == url' do
        it 'makes no request' do
          allow(foo).to receive(:[]).with(attribute_name).and_return(url)

          foo.hoge_remote_url = url
          expect(request).not_to have_been_requested
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
            expect(foo).not_to receive(:send).with("#{hoge}=", any_args)
            expect(foo).not_to receive(:send).with("#{hoge}_file_name=", any_args)
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

              expect(foo).to receive(:send).with("#{hoge}=", string_io)
              expect(foo).to receive(:send).with("#{hoge}_file_name=", basename + extname)
              foo.hoge_remote_url = url
            end
          end

          context 'if has_attribute?' do
            it 'calls foo[attribute_name] = url' do
              allow(foo).to receive(:has_attribute?).with(attribute_name).and_return(true)
              expect(foo).to receive('[]=').with(attribute_name, url)
              foo.hoge_remote_url = url
            end
          end

          context 'unless has_attribute?' do
            it 'calls not foo[attribute_name] = url' do
              allow(foo).to receive(:has_attribute?)
                .with(attribute_name).and_return(false)
              expect(foo).not_to receive('[]=').with(attribute_name, url)
              foo.hoge_remote_url = url
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

    describe '#reset_hoge!' do
      context 'if url.blank?' do
        it 'returns nil, without clearing foo[attribute_name] and calling #hoge_remote_url=' do
          url = nil
          expect(foo).not_to receive(:send).with(:hoge_remote_url=, url)
          foo[attribute_name] = url
          expect(foo.reset_hoge!).to be_nil
          expect(foo[attribute_name]).to be_nil
        end
      end

      context 'unless url.blank?' do
        it 'clears foo[attribute_name] and calls #hoge_remote_url=' do
          foo[attribute_name] = url
          expect(foo).to receive(:send).with(:hoge_remote_url=, url)
          foo.reset_hoge!
          expect(foo[attribute_name]).to be ''
        end
      end
    end
  end
end
