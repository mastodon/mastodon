require 'spec_helper'

describe Excon::Error do
  # Regression against e300458f2d9330cb265baeb8973120d08c665d9
  describe '#status_errors' do
    describe '.keys ' do
      expected = [
        100,
        101,
        (200..206).to_a,
        (300..307).to_a,
        (400..417).to_a,
        422,
        429,
        (500..504).to_a
      ].flatten

      it('returns the pertinent HTTP error numbers') do
        expected.flatten == Excon::Error.status_errors.keys
      end
    end
  end

  describe '#new' do
    it('returns an Excon::Error') do
      expect(Excon::Error.new('bar').class == Excon::Error).to be true
    end
    it('raises errors for bad URIs') do
      expect { Excon.new('foo') }.to raise_error(ArgumentError)
    end

    it('raises errors for bad paths') do
      expect { Excon.new('http://localhost', path: "foo\r\nbar: baz") }.to raise_error(URI::InvalidURIError)
    end
  end

  context 'when remaining backwards compatible' do
    describe '#new' do
      it 'should raise standard error and catch standard error' do
        expect { raise Excon::Error::Client, 'foo' }.to raise_error(Excon::Error)
      end

      it 'should raise legacy errors and catch legacy errors' do
        expect do
          raise Excon::Errors::Error, 'bar'
        end.to raise_error(Excon::Errors::Error)
      end

      it 'should raise standard error and catch legacy errors' do
        expect do
          raise Excon::Error::NotFound, 'bar'
        end.to raise_error(Excon::Errors::Error)
      end
    end

    describe '#status_error' do
      it 'should raise with status_error() and catch with standard error' do
        expect do
          raise Excon::Error.status_error({ expects: 200 }, status: 400)
        end.to raise_error(Excon::Error)
      end

      it 'should raise with  status_error() and catch with legacy error' do
        expect do
          raise Excon::Error.status_error({ expects: 200 }, status: 400)
        end.to raise_error(Excon::Errors::BadRequest)
      end

      it 'should raise with legacy status_error() and catch with standard' do
        expect do
          raise Excon::Errors.status_error({ expects: 200 }, status: 400)
        end.to raise_error(Excon::Error)
      end
    end
  end

  context 'when exceptions are rescued' do
    include_context("test server", :exec, 'error.rb', :before => :start, :after => :stop )

    context 'when :debug_request and :debug_response are switched off' do
      it('exception message does not include response or response info') do
        begin
          Excon.get('http://127.0.0.1:9292/error/not_found', expects: 200)
        rescue Excon::Errors::HTTPStatusError => err
          truth =
            err.message.include?('Expected(200) <=> Actual(404 Not Found)') &&
            !err.message.include?('excon.error.request') &&
            !err.message.include?('excon.error.response')
          expect(truth).to be true
        end
      end
    end

    context 'when :debug_request and :debug_response are switched on' do
      it 'exception message includes request and response info' do
        begin
          Excon.get('http://127.0.0.1:9292/error/not_found', expects: 200,
                                                             debug_request: true, debug_response: true)
        rescue Excon::Errors::HTTPStatusError => err
          truth =
            err.message.include?('Expected(200) <=> Actual(404 Not Found)') &&
            err.message.include?('excon.error.request') &&
            err.message.include?('excon.error.response')
          expect(truth).to be true
        end
      end
    end

    context 'when only :debug_request is turned on' do
      it('exception message includes only request info') do
        begin
          Excon.get('http://127.0.0.1:9292/error/not_found', expects: 200,
                                                             debug_request: true)
        rescue Excon::Errors::HTTPStatusError => err
          truth =
            err.message.include?('Expected(200) <=> Actual(404 Not Found)') &&
            err.message.include?('excon.error.request') &&
            !err.message.include?('excon.error.response')
          expect(truth).to be true
        end
      end
    end

    context 'when only :debug_response is turned on ' do
      it('exception message includes only response info') do
        begin
          Excon.get('http://127.0.0.1:9292/error/not_found', expects: 200,
                                                             debug_response: true)
        rescue Excon::Errors::HTTPStatusError => err
          truth =
            err.message.include?('Expected(200) <=> Actual(404 Not Found)') &&
            !err.message.include?('excon.error.request') &&
            err.message.include?('excon.error.response')
          expect(truth).to be true
        end
      end
    end
  end
end
