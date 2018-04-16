# frozen_string_literal: true

RSpec.describe HTTP::Redirector do
  def simple_response(status, body = "", headers = {})
    HTTP::Response.new(
      :status  => status,
      :version => "1.1",
      :headers => headers,
      :body    => body
    )
  end

  def redirect_response(status, location)
    simple_response status, "", "Location" => location
  end

  describe "#strict" do
    subject { redirector.strict }

    context "by default" do
      let(:redirector) { described_class.new }
      it { is_expected.to be true }
    end
  end

  describe "#max_hops" do
    subject { redirector.max_hops }

    context "by default" do
      let(:redirector) { described_class.new }
      it { is_expected.to eq 5 }
    end
  end

  describe "#perform" do
    let(:options)    { {} }
    let(:redirector) { described_class.new options }

    it "fails with TooManyRedirectsError if max hops reached" do
      req = HTTP::Request.new :verb => :head, :uri => "http://example.com"
      res = proc { |prev_req| redirect_response(301, "#{prev_req.uri}/1") }

      expect { redirector.perform(req, res.call(req), &res) }.
        to raise_error HTTP::Redirector::TooManyRedirectsError
    end

    it "fails with EndlessRedirectError if endless loop detected" do
      req = HTTP::Request.new :verb => :head, :uri => "http://example.com"
      res = redirect_response(301, req.uri)

      expect { redirector.perform(req, res) { res } }.
        to raise_error HTTP::Redirector::EndlessRedirectError
    end

    it "fails with StateError if there were no Location header" do
      req = HTTP::Request.new :verb => :head, :uri => "http://example.com"
      res = simple_response(301)

      expect { |b| redirector.perform(req, res, &b) }.
        to raise_error HTTP::StateError
    end

    it "returns first non-redirect response" do
      req  = HTTP::Request.new :verb => :head, :uri => "http://example.com"
      hops = [
        redirect_response(301, "http://example.com/1"),
        redirect_response(301, "http://example.com/2"),
        redirect_response(301, "http://example.com/3"),
        simple_response(200, "foo"),
        redirect_response(301, "http://example.com/4"),
        simple_response(200, "bar")
      ]

      res = redirector.perform(req, hops.shift) { hops.shift }
      expect(res.to_s).to eq "foo"
    end

    context "following 300 redirect" do
      context "with strict mode" do
        let(:options) { {:strict => true} }

        it "it follows with original verb if it's safe" do
          req = HTTP::Request.new :verb => :head, :uri => "http://example.com"
          res = redirect_response 300, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :head
            simple_response 200
          end
        end

        it "raises StateError if original request was PUT" do
          req = HTTP::Request.new :verb => :put, :uri => "http://example.com"
          res = redirect_response 300, "http://example.com/1"

          expect { redirector.perform(req, res) { simple_response 200 } }.
            to raise_error HTTP::StateError
        end

        it "raises StateError if original request was POST" do
          req = HTTP::Request.new :verb => :post, :uri => "http://example.com"
          res = redirect_response 300, "http://example.com/1"

          expect { redirector.perform(req, res) { simple_response 200 } }.
            to raise_error HTTP::StateError
        end

        it "raises StateError if original request was DELETE" do
          req = HTTP::Request.new :verb => :delete, :uri => "http://example.com"
          res = redirect_response 300, "http://example.com/1"

          expect { redirector.perform(req, res) { simple_response 200 } }.
            to raise_error HTTP::StateError
        end
      end

      context "with non-strict mode" do
        let(:options) { {:strict => false} }

        it "it follows with original verb if it's safe" do
          req = HTTP::Request.new :verb => :head, :uri => "http://example.com"
          res = redirect_response 300, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :head
            simple_response 200
          end
        end

        it "it follows with GET if original request was PUT" do
          req = HTTP::Request.new :verb => :put, :uri => "http://example.com"
          res = redirect_response 300, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :get
            simple_response 200
          end
        end

        it "it follows with GET if original request was POST" do
          req = HTTP::Request.new :verb => :post, :uri => "http://example.com"
          res = redirect_response 300, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :get
            simple_response 200
          end
        end

        it "it follows with GET if original request was DELETE" do
          req = HTTP::Request.new :verb => :delete, :uri => "http://example.com"
          res = redirect_response 300, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :get
            simple_response 200
          end
        end
      end
    end

    context "following 301 redirect" do
      context "with strict mode" do
        let(:options) { {:strict => true} }

        it "it follows with original verb if it's safe" do
          req = HTTP::Request.new :verb => :head, :uri => "http://example.com"
          res = redirect_response 301, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :head
            simple_response 200
          end
        end

        it "raises StateError if original request was PUT" do
          req = HTTP::Request.new :verb => :put, :uri => "http://example.com"
          res = redirect_response 301, "http://example.com/1"

          expect { redirector.perform(req, res) { simple_response 200 } }.
            to raise_error HTTP::StateError
        end

        it "raises StateError if original request was POST" do
          req = HTTP::Request.new :verb => :post, :uri => "http://example.com"
          res = redirect_response 301, "http://example.com/1"

          expect { redirector.perform(req, res) { simple_response 200 } }.
            to raise_error HTTP::StateError
        end

        it "raises StateError if original request was DELETE" do
          req = HTTP::Request.new :verb => :delete, :uri => "http://example.com"
          res = redirect_response 301, "http://example.com/1"

          expect { redirector.perform(req, res) { simple_response 200 } }.
            to raise_error HTTP::StateError
        end
      end

      context "with non-strict mode" do
        let(:options) { {:strict => false} }

        it "it follows with original verb if it's safe" do
          req = HTTP::Request.new :verb => :head, :uri => "http://example.com"
          res = redirect_response 301, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :head
            simple_response 200
          end
        end

        it "it follows with GET if original request was PUT" do
          req = HTTP::Request.new :verb => :put, :uri => "http://example.com"
          res = redirect_response 301, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :get
            simple_response 200
          end
        end

        it "it follows with GET if original request was POST" do
          req = HTTP::Request.new :verb => :post, :uri => "http://example.com"
          res = redirect_response 301, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :get
            simple_response 200
          end
        end

        it "it follows with GET if original request was DELETE" do
          req = HTTP::Request.new :verb => :delete, :uri => "http://example.com"
          res = redirect_response 301, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :get
            simple_response 200
          end
        end
      end
    end

    context "following 302 redirect" do
      context "with strict mode" do
        let(:options) { {:strict => true} }

        it "it follows with original verb if it's safe" do
          req = HTTP::Request.new :verb => :head, :uri => "http://example.com"
          res = redirect_response 302, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :head
            simple_response 200
          end
        end

        it "raises StateError if original request was PUT" do
          req = HTTP::Request.new :verb => :put, :uri => "http://example.com"
          res = redirect_response 302, "http://example.com/1"

          expect { redirector.perform(req, res) { simple_response 200 } }.
            to raise_error HTTP::StateError
        end

        it "raises StateError if original request was POST" do
          req = HTTP::Request.new :verb => :post, :uri => "http://example.com"
          res = redirect_response 302, "http://example.com/1"

          expect { redirector.perform(req, res) { simple_response 200 } }.
            to raise_error HTTP::StateError
        end

        it "raises StateError if original request was DELETE" do
          req = HTTP::Request.new :verb => :delete, :uri => "http://example.com"
          res = redirect_response 302, "http://example.com/1"

          expect { redirector.perform(req, res) { simple_response 200 } }.
            to raise_error HTTP::StateError
        end
      end

      context "with non-strict mode" do
        let(:options) { {:strict => false} }

        it "it follows with original verb if it's safe" do
          req = HTTP::Request.new :verb => :head, :uri => "http://example.com"
          res = redirect_response 302, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :head
            simple_response 200
          end
        end

        it "it follows with GET if original request was PUT" do
          req = HTTP::Request.new :verb => :put, :uri => "http://example.com"
          res = redirect_response 302, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :get
            simple_response 200
          end
        end

        it "it follows with GET if original request was POST" do
          req = HTTP::Request.new :verb => :post, :uri => "http://example.com"
          res = redirect_response 302, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :get
            simple_response 200
          end
        end

        it "it follows with GET if original request was DELETE" do
          req = HTTP::Request.new :verb => :delete, :uri => "http://example.com"
          res = redirect_response 302, "http://example.com/1"

          redirector.perform(req, res) do |prev_req, _|
            expect(prev_req.verb).to be :get
            simple_response 200
          end
        end
      end
    end

    context "following 303 redirect" do
      it "follows with HEAD if original request was HEAD" do
        req = HTTP::Request.new :verb => :head, :uri => "http://example.com"
        res = redirect_response 303, "http://example.com/1"

        redirector.perform(req, res) do |prev_req, _|
          expect(prev_req.verb).to be :head
          simple_response 200
        end
      end

      it "follows with GET if original request was GET" do
        req = HTTP::Request.new :verb => :get, :uri => "http://example.com"
        res = redirect_response 303, "http://example.com/1"

        redirector.perform(req, res) do |prev_req, _|
          expect(prev_req.verb).to be :get
          simple_response 200
        end
      end

      it "follows with GET if original request was neither GET nor HEAD" do
        req = HTTP::Request.new :verb => :post, :uri => "http://example.com"
        res = redirect_response 303, "http://example.com/1"

        redirector.perform(req, res) do |prev_req, _|
          expect(prev_req.verb).to be :get
          simple_response 200
        end
      end
    end

    context "following 307 redirect" do
      it "follows with original request's verb" do
        req = HTTP::Request.new :verb => :post, :uri => "http://example.com"
        res = redirect_response 307, "http://example.com/1"

        redirector.perform(req, res) do |prev_req, _|
          expect(prev_req.verb).to be :post
          simple_response 200
        end
      end
    end

    context "following 308 redirect" do
      it "follows with original request's verb" do
        req = HTTP::Request.new :verb => :post, :uri => "http://example.com"
        res = redirect_response 308, "http://example.com/1"

        redirector.perform(req, res) do |prev_req, _|
          expect(prev_req.verb).to be :post
          simple_response 200
        end
      end
    end
  end
end
