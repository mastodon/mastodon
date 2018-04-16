# coding: utf-8
require_relative 'spec_helper'

describe JSON::LD::API do
  let(:logger) {RDF::Spec.logger}

  describe "#initialize" do
    context "with string input" do
      let(:context) do
        JSON::LD::API::RemoteDocument.new("http://example.com/context", %q({
          "@context": {
            "xsd": "http://www.w3.org/2001/XMLSchema#",
            "name": "http://xmlns.com/foaf/0.1/name",
            "homepage": {"@id": "http://xmlns.com/foaf/0.1/homepage", "@type": "@id"},
            "avatar": {"@id": "http://xmlns.com/foaf/0.1/avatar", "@type": "@id"}
          }
        }))
      end
      let(:remote_doc) do
        JSON::LD::API::RemoteDocument.new("http://example.com/foo", %q({
          "@id": "",
          "name": "foo"
        }), "http://example.com/context")
      end

      it "loads document with loader and loads context" do
        expect(described_class).to receive(:documentLoader).with("http://example.com/foo", anything).and_return(remote_doc)
        expect(described_class).to receive(:documentLoader).with("http://example.com/context", anything).and_yield(context)
        described_class.new("http://example.com/foo", nil)
      end
    end

    context "with RDF::Util::File::RemoteDoc input" do
      let(:context) do
        JSON::LD::API::RemoteDocument.new("http://example.com/context", %q({
          "@context": {
            "xsd": "http://www.w3.org/2001/XMLSchema#",
            "name": "http://xmlns.com/foaf/0.1/name",
            "homepage": {"@id": "http://xmlns.com/foaf/0.1/homepage", "@type": "@id"},
            "avatar": {"@id": "http://xmlns.com/foaf/0.1/avatar", "@type": "@id"}
          }
        }))
      end
      let(:remote_doc) do
        RDF::Util::File::RemoteDocument.new(%q({"@id": "", "name": "foo"}),
          headers: {
            content_type: 'application/json',
            link: %(<http://example.com/context>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json")
          }
        )
      end

      it "processes document and retrieves linked context" do
        expect(described_class).to receive(:documentLoader).with("http://example.com/context", anything).and_yield(context)
        described_class.new(remote_doc, nil)
      end
    end
  end

  context "when validating", pending: ("JRuby support for jsonlint" if RUBY_ENGINE == "jruby") do
    it "detects invalid JSON" do
      expect {described_class.new(StringIO.new(%({"a": "b", "a": "c"})), nil, validate: true)}.to raise_error(JSON::LD::JsonLdError::LoadingDocumentFailed)
    end
  end

  context "Test Files" do
    %w(oj json_gem ok_json yajl).map(&:to_sym).each do |adapter|
      context "with MultiJson adapter #{adapter.inspect}" do
        Dir.glob(File.expand_path(File.join(File.dirname(__FILE__), 'test-files/*-input.*'))) do |filename|
          test = File.basename(filename).sub(/-input\..*$/, '')
          frame = filename.sub(/-input\..*$/, '-frame.json')
          framed = filename.sub(/-input\..*$/, '-framed.json')
          compacted = filename.sub(/-input\..*$/, '-compacted.json')
          context = filename.sub(/-input\..*$/, '-context.json')
          expanded = filename.sub(/-input\..*$/, '-expanded.json')
          ttl = filename.sub(/-input\..*$/, '-rdf.ttl')
      
          context test, skip: ("Not supported in JRuby" if RUBY_ENGINE == "jruby" && %w(oj yajl).include?(adapter.to_s)) do
            it "expands" do
              options = {logger: logger, adapter: adapter}
              options[:expandContext] = File.open(context) if context
              jld = described_class.expand(File.open(filename), options)
              expect(jld).to produce(JSON.load(File.open(expanded)), logger)
            end if File.exist?(expanded)
        
            it "compacts" do
              jld = described_class.compact(File.open(filename), File.open(context), adapter: adapter, logger: logger)
              expect(jld).to produce(JSON.load(File.open(compacted)), logger)
            end if File.exist?(compacted) && File.exist?(context)
        
            it "frame" do
              jld = described_class.frame(File.open(filename), File.open(frame), adapter: adapter, logger: logger)
              expect(jld).to produce(JSON.load(File.open(framed)), logger)
            end if File.exist?(framed) && File.exist?(frame)

            it "toRdf" do
              expect(RDF::Repository.load(filename, format: :jsonld, adapter: adapter, logger: logger)).to be_equivalent_graph(RDF::Repository.load(ttl), logger: logger)
            end if File.exist?(ttl)
          end
        end
      end
    end
  end
end
