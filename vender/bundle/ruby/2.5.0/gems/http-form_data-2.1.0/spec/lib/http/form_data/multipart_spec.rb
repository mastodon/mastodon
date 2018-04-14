# frozen_string_literal: true

RSpec.describe HTTP::FormData::Multipart do
  subject(:form_data) { HTTP::FormData::Multipart.new params }

  let(:file)          { HTTP::FormData::File.new fixture "the-http-gem.info" }
  let(:params)        { { :foo => :bar, :baz => file } }
  let(:boundary)      { /-{21}[a-f0-9]{42}/ }

  describe "#to_s" do
    def disposition(params)
      params = params.map { |k, v| "#{k}=#{v.inspect}" }.join("; ")
      "Content-Disposition: form-data; #{params}"
    end

    let(:crlf) { "\r\n" }

    it "properly generates multipart data" do
      boundary_value = form_data.boundary

      expect(form_data.to_s).to eq [
        "--#{boundary_value}#{crlf}",
        "#{disposition 'name' => 'foo'}#{crlf}",
        "#{crlf}bar#{crlf}",
        "--#{boundary_value}#{crlf}",
        "#{disposition 'name' => 'baz', 'filename' => file.filename}#{crlf}",
        "Content-Type: #{file.content_type}#{crlf}",
        "#{crlf}#{file}#{crlf}",
        "--#{boundary_value}--#{crlf}"
      ].join("")
    end

    it "rewinds content" do
      content = form_data.read
      expect(form_data.to_s).to eq content
      expect(form_data.read).to eq content
    end

    context "with user-defined boundary" do
      subject(:form_data) do
        HTTP::FormData::Multipart.new params, :boundary => "my-boundary"
      end

      it "uses the given boundary" do
        expect(form_data.to_s).to eq [
          "--my-boundary#{crlf}",
          "#{disposition 'name' => 'foo'}#{crlf}",
          "#{crlf}bar#{crlf}",
          "--my-boundary#{crlf}",
          "#{disposition 'name' => 'baz', 'filename' => file.filename}#{crlf}",
          "Content-Type: #{file.content_type}#{crlf}",
          "#{crlf}#{file}#{crlf}",
          "--my-boundary--#{crlf}"
        ].join("")
      end
    end

    context "with filename set to nil" do
      let(:part) { HTTP::FormData::Part.new("s", :content_type => "mime/type") }
      let(:form_data) { HTTP::FormData::Multipart.new(:foo => part) }

      it "doesn't include a filename" do
        boundary_value = form_data.content_type[/(#{boundary})$/, 1]

        expect(form_data.to_s).to eq [
          "--#{boundary_value}#{crlf}",
          "#{disposition 'name' => 'foo'}#{crlf}",
          "Content-Type: #{part.content_type}#{crlf}",
          "#{crlf}s#{crlf}",
          "--#{boundary_value}--#{crlf}"
        ].join("")
      end
    end

    context "with content type set to nil" do
      let(:part) { HTTP::FormData::Part.new("s") }
      let(:form_data) { HTTP::FormData::Multipart.new(:foo => part) }

      it "doesn't include a filename" do
        boundary_value = form_data.content_type[/(#{boundary})$/, 1]

        expect(form_data.to_s).to eq [
          "--#{boundary_value}#{crlf}",
          "#{disposition 'name' => 'foo'}#{crlf}",
          "#{crlf}s#{crlf}",
          "--#{boundary_value}--#{crlf}"
        ].join("")
      end
    end
  end

  describe "#size" do
    it "returns bytesize of multipart data" do
      expect(form_data.size).to eq form_data.to_s.bytesize
    end
  end

  describe "#read" do
    it "returns multipart data" do
      expect(form_data.read).to eq form_data.to_s
    end
  end

  describe "#rewind" do
    it "rewinds the multipart data IO" do
      form_data.read
      form_data.rewind
      expect(form_data.read).to eq form_data.to_s
    end
  end

  describe "#content_type" do
    subject { form_data.content_type }

    let(:content_type) { %r{^multipart\/form-data; boundary=#{boundary}$} }

    it { is_expected.to match(content_type) }

    context "with user-defined boundary" do
      let(:form_data) do
        HTTP::FormData::Multipart.new params, :boundary => "my-boundary"
      end

      it "includes the given boundary" do
        expect(form_data.content_type)
          .to eq "multipart/form-data; boundary=my-boundary"
      end
    end
  end

  describe "#content_length" do
    subject { form_data.content_length }
    it { is_expected.to eq form_data.to_s.bytesize }
  end

  describe "#boundary" do
    it "returns a new boundary" do
      expect(form_data.boundary).to match(boundary)
    end

    context "with user-defined boundary" do
      let(:form_data) do
        HTTP::FormData::Multipart.new params, :boundary => "my-boundary"
      end

      it "returns the given boundary" do
        expect(form_data.boundary).to eq "my-boundary"
      end
    end
  end

  describe ".generate_boundary" do
    it "returns a string suitable as a multipart boundary" do
      expect(form_data.class.generate_boundary).to match(boundary)
    end
  end
end
