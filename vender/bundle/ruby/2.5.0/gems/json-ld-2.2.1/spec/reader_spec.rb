# coding: utf-8
require_relative 'spec_helper'
require 'rdf/spec/reader'

describe JSON::LD::Reader do
  let!(:doap) {File.expand_path("../../etc/doap.jsonld", __FILE__)}
  let!(:doap_nt) {File.expand_path("../../etc/doap.nt", __FILE__)}
  let!(:doap_count) {File.open(doap_nt).each_line.to_a.length}
  let(:logger) {RDF::Spec.logger}

  after(:each) {|example| puts logger.to_s if example.exception}

  it_behaves_like 'an RDF::Reader' do
    let(:reader_input) {File.read(doap)}
    let(:reader) {JSON::LD::Reader.new(reader_input)}
    let(:reader_count) {doap_count}
  end

  describe ".for" do
    formats = [
      :jsonld,
      "etc/doap.jsonld",
      {file_name:      'etc/doap.jsonld'},
      {file_extension: 'jsonld'},
      {content_type:   'application/ld+json'},
      {content_type:   'application/x-ld+json'},
    ].each do |arg|
      it "discovers with #{arg.inspect}" do
        expect(RDF::Reader.for(arg)).to eq JSON::LD::Reader
      end
    end
  end

  context "when validating", pending: ("JRuby support for jsonlint" if RUBY_ENGINE == "jruby") do
    it "detects invalid JSON" do
      expect do |b|
        described_class.new(StringIO.new(%({"a": "b", "a": "c"})), validate: true, logger: false).each_statement(&b)
      end.to raise_error(RDF::ReaderError)
    end
  end

  context :interface do
    {
      plain: %q({
        "@context": {"foaf": "http://xmlns.com/foaf/0.1/"},
         "@id": "_:bnode1",
         "@type": "foaf:Person",
         "foaf:homepage": "http://example.com/bob/",
         "foaf:name": "Bob"
       }),
       leading_comment: %q(
         // A comment before content
         {
           "@context": {"foaf": "http://xmlns.com/foaf/0.1/"},
            "@id": "_:bnode1",
            "@type": "foaf:Person",
            "foaf:homepage": "http://example.com/bob/",
            "foaf:name": "Bob"
          }
         ),
       script: %q(<script type="application/ld+json">
         {
           "@context": {"foaf": "http://xmlns.com/foaf/0.1/"},
            "@id": "_:bnode1",
            "@type": "foaf:Person",
            "foaf:homepage": "http://example.com/bob/",
            "foaf:name": "Bob"
          }
         </script>),
       script_comments: %q(<script type="application/ld+json">
         // A comment before content
         {
           "@context": {"foaf": "http://xmlns.com/foaf/0.1/"},
            "@id": "_:bnode1",
            "@type": "foaf:Person",
            "foaf:homepage": "http://example.com/bob/",
            "foaf:name": "Bob"
          }
         </script>),
    }.each do |variant, src|
      context variant do
        subject {src}

        describe "#initialize" do
          it "yields reader given string" do
            inner = double("inner")
            expect(inner).to receive(:called).with(JSON::LD::Reader)
            JSON::LD::Reader.new(subject) do |reader|
              inner.called(reader.class)
            end
          end

          it "yields reader given IO" do
            inner = double("inner")
            expect(inner).to receive(:called).with(JSON::LD::Reader)
            JSON::LD::Reader.new(StringIO.new(subject)) do |reader|
              inner.called(reader.class)
            end
          end

          it "returns reader" do
            expect(JSON::LD::Reader.new(subject)).to be_a(JSON::LD::Reader)
          end
        end

        describe "#each_statement" do
          it "yields statements" do
            inner = double("inner")
            expect(inner).to receive(:called).with(RDF::Statement).exactly(3)
            JSON::LD::Reader.new(subject).each_statement do |statement|
              inner.called(statement.class)
            end
          end
        end

        describe "#each_triple" do
          it "yields statements" do
            inner = double("inner")
            expect(inner).to receive(:called).exactly(3)
            JSON::LD::Reader.new(subject).each_triple do |subject, predicate, object|
              inner.called(subject.class, predicate.class, object.class)
            end
          end
        end
      end
    end
  end

  describe "Base IRI resolution" do
    # From https://gist.github.com/RubenVerborgh/39f0e8d63e33e435371a
    let(:json) {%q{[
      {
        "@context": {"@base": "http://a/bb/ccc/d;p?q", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s001", "urn:ex:p": "g:h"},
          {"@id": "urn:ex:s002", "urn:ex:p": "g"},
          {"@id": "urn:ex:s003", "urn:ex:p": "./g"},
          {"@id": "urn:ex:s004", "urn:ex:p": "g/"},
          {"@id": "urn:ex:s005", "urn:ex:p": "/g"},
          {"@id": "urn:ex:s006", "urn:ex:p": "//g"},
          {"@id": "urn:ex:s007", "urn:ex:p": "?y"},
          {"@id": "urn:ex:s008", "urn:ex:p": "g?y"},
          {"@id": "urn:ex:s009", "urn:ex:p": "#s"},
          {"@id": "urn:ex:s010", "urn:ex:p": "g#s"},
          {"@id": "urn:ex:s011", "urn:ex:p": "g?y#s"},
          {"@id": "urn:ex:s012", "urn:ex:p": ";x"},
          {"@id": "urn:ex:s013", "urn:ex:p": "g;x"},
          {"@id": "urn:ex:s014", "urn:ex:p": "g;x?y#s"},
          {"@id": "urn:ex:s015", "urn:ex:p": ""},
          {"@id": "urn:ex:s016", "urn:ex:p": "."},
          {"@id": "urn:ex:s017", "urn:ex:p": "./"},
          {"@id": "urn:ex:s018", "urn:ex:p": ".."},
          {"@id": "urn:ex:s019", "urn:ex:p": "../"},
          {"@id": "urn:ex:s020", "urn:ex:p": "../g"},
          {"@id": "urn:ex:s021", "urn:ex:p": "../.."},
          {"@id": "urn:ex:s022", "urn:ex:p": "../../"},
          {"@id": "urn:ex:s023", "urn:ex:p": "../../g"}
        ]
      },
      {
        "@context": {"@base": "http://a/bb/ccc/d;p?q", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s024", "urn:ex:p": "../../../g"},
          {"@id": "urn:ex:s025", "urn:ex:p": "../../../../g"},
          {"@id": "urn:ex:s026", "urn:ex:p": "/./g"},
          {"@id": "urn:ex:s027", "urn:ex:p": "/../g"},
          {"@id": "urn:ex:s028", "urn:ex:p": "g."},
          {"@id": "urn:ex:s029", "urn:ex:p": ".g"},
          {"@id": "urn:ex:s030", "urn:ex:p": "g.."},
          {"@id": "urn:ex:s031", "urn:ex:p": "..g"},
          {"@id": "urn:ex:s032", "urn:ex:p": "./../g"},
          {"@id": "urn:ex:s033", "urn:ex:p": "./g/."},
          {"@id": "urn:ex:s034", "urn:ex:p": "g/./h"},
          {"@id": "urn:ex:s035", "urn:ex:p": "g/../h"},
          {"@id": "urn:ex:s036", "urn:ex:p": "g;x=1/./y"},
          {"@id": "urn:ex:s037", "urn:ex:p": "g;x=1/../y"},
          {"@id": "urn:ex:s038", "urn:ex:p": "g?y/./x"},
          {"@id": "urn:ex:s039", "urn:ex:p": "g?y/../x"},
          {"@id": "urn:ex:s040", "urn:ex:p": "g#s/./x"},
          {"@id": "urn:ex:s041", "urn:ex:p": "g#s/../x"},
          {"@id": "urn:ex:s042", "urn:ex:p": "http:g"}
        ]
      },
      {
        "@context": {"@base": "http://a/bb/ccc/d/", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s043", "urn:ex:p": "g:h"},
          {"@id": "urn:ex:s044", "urn:ex:p": "g"},
          {"@id": "urn:ex:s045", "urn:ex:p": "./g"},
          {"@id": "urn:ex:s046", "urn:ex:p": "g/"},
          {"@id": "urn:ex:s047", "urn:ex:p": "/g"},
          {"@id": "urn:ex:s048", "urn:ex:p": "//g"},
          {"@id": "urn:ex:s049", "urn:ex:p": "?y"},
          {"@id": "urn:ex:s050", "urn:ex:p": "g?y"},
          {"@id": "urn:ex:s051", "urn:ex:p": "#s"},
          {"@id": "urn:ex:s052", "urn:ex:p": "g#s"},
          {"@id": "urn:ex:s053", "urn:ex:p": "g?y#s"},
          {"@id": "urn:ex:s054", "urn:ex:p": ";x"},
          {"@id": "urn:ex:s055", "urn:ex:p": "g;x"},
          {"@id": "urn:ex:s056", "urn:ex:p": "g;x?y#s"},
          {"@id": "urn:ex:s057", "urn:ex:p": ""},
          {"@id": "urn:ex:s058", "urn:ex:p": "."},
          {"@id": "urn:ex:s059", "urn:ex:p": "./"},
          {"@id": "urn:ex:s060", "urn:ex:p": ".."},
          {"@id": "urn:ex:s061", "urn:ex:p": "../"},
          {"@id": "urn:ex:s062", "urn:ex:p": "../g"},
          {"@id": "urn:ex:s063", "urn:ex:p": "../.."},
          {"@id": "urn:ex:s064", "urn:ex:p": "../../"},
          {"@id": "urn:ex:s065", "urn:ex:p": "../../g"}
        ]
      },
      {
        "@context": {"@base": "http://a/bb/ccc/d/", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s066", "urn:ex:p": "../../../g"},
          {"@id": "urn:ex:s067", "urn:ex:p": "../../../../g"},
          {"@id": "urn:ex:s068", "urn:ex:p": "/./g"},
          {"@id": "urn:ex:s069", "urn:ex:p": "/../g"},
          {"@id": "urn:ex:s070", "urn:ex:p": "g."},
          {"@id": "urn:ex:s071", "urn:ex:p": ".g"},
          {"@id": "urn:ex:s072", "urn:ex:p": "g.."},
          {"@id": "urn:ex:s073", "urn:ex:p": "..g"},
          {"@id": "urn:ex:s074", "urn:ex:p": "./../g"},
          {"@id": "urn:ex:s075", "urn:ex:p": "./g/."},
          {"@id": "urn:ex:s076", "urn:ex:p": "g/./h"},
          {"@id": "urn:ex:s077", "urn:ex:p": "g/../h"},
          {"@id": "urn:ex:s078", "urn:ex:p": "g;x=1/./y"},
          {"@id": "urn:ex:s079", "urn:ex:p": "g;x=1/../y"},
          {"@id": "urn:ex:s080", "urn:ex:p": "g?y/./x"},
          {"@id": "urn:ex:s081", "urn:ex:p": "g?y/../x"},
          {"@id": "urn:ex:s082", "urn:ex:p": "g#s/./x"},
          {"@id": "urn:ex:s083", "urn:ex:p": "g#s/../x"},
          {"@id": "urn:ex:s084", "urn:ex:p": "http:g"}
        ]
      },
      {
        "@context": {"@base": "http://a/bb/ccc/./d;p?q", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s085", "urn:ex:p": "g:h"},
          {"@id": "urn:ex:s086", "urn:ex:p": "g"},
          {"@id": "urn:ex:s087", "urn:ex:p": "./g"},
          {"@id": "urn:ex:s088", "urn:ex:p": "g/"},
          {"@id": "urn:ex:s089", "urn:ex:p": "/g"},
          {"@id": "urn:ex:s090", "urn:ex:p": "//g"},
          {"@id": "urn:ex:s091", "urn:ex:p": "?y"},
          {"@id": "urn:ex:s092", "urn:ex:p": "g?y"},
          {"@id": "urn:ex:s093", "urn:ex:p": "#s"},
          {"@id": "urn:ex:s094", "urn:ex:p": "g#s"},
          {"@id": "urn:ex:s095", "urn:ex:p": "g?y#s"},
          {"@id": "urn:ex:s096", "urn:ex:p": ";x"},
          {"@id": "urn:ex:s097", "urn:ex:p": "g;x"},
          {"@id": "urn:ex:s098", "urn:ex:p": "g;x?y#s"},
          {"@id": "urn:ex:s099", "urn:ex:p": ""},
          {"@id": "urn:ex:s100", "urn:ex:p": "."},
          {"@id": "urn:ex:s101", "urn:ex:p": "./"},
          {"@id": "urn:ex:s102", "urn:ex:p": ".."},
          {"@id": "urn:ex:s103", "urn:ex:p": "../"},
          {"@id": "urn:ex:s104", "urn:ex:p": "../g"},
          {"@id": "urn:ex:s105", "urn:ex:p": "../.."},
          {"@id": "urn:ex:s106", "urn:ex:p": "../../"},
          {"@id": "urn:ex:s107", "urn:ex:p": "../../g"}
        ]
      },
      {
        "@context": {"@base": "http://a/bb/ccc/./d;p?q", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s108", "urn:ex:p": "../../../g"},
          {"@id": "urn:ex:s109", "urn:ex:p": "../../../../g"},
          {"@id": "urn:ex:s110", "urn:ex:p": "/./g"},
          {"@id": "urn:ex:s111", "urn:ex:p": "/../g"},
          {"@id": "urn:ex:s112", "urn:ex:p": "g."},
          {"@id": "urn:ex:s113", "urn:ex:p": ".g"},
          {"@id": "urn:ex:s114", "urn:ex:p": "g.."},
          {"@id": "urn:ex:s115", "urn:ex:p": "..g"},
          {"@id": "urn:ex:s116", "urn:ex:p": "./../g"},
          {"@id": "urn:ex:s117", "urn:ex:p": "./g/."},
          {"@id": "urn:ex:s118", "urn:ex:p": "g/./h"},
          {"@id": "urn:ex:s119", "urn:ex:p": "g/../h"},
          {"@id": "urn:ex:s120", "urn:ex:p": "g;x=1/./y"},
          {"@id": "urn:ex:s121", "urn:ex:p": "g;x=1/../y"},
          {"@id": "urn:ex:s122", "urn:ex:p": "g?y/./x"},
          {"@id": "urn:ex:s123", "urn:ex:p": "g?y/../x"},
          {"@id": "urn:ex:s124", "urn:ex:p": "g#s/./x"},
          {"@id": "urn:ex:s125", "urn:ex:p": "g#s/../x"},
          {"@id": "urn:ex:s126", "urn:ex:p": "http:g"}
        ]
      },
      {
        "@context": {"@base": "http://a/bb/ccc/../d;p?q", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s127", "urn:ex:p": "g:h"},
          {"@id": "urn:ex:s128", "urn:ex:p": "g"},
          {"@id": "urn:ex:s129", "urn:ex:p": "./g"},
          {"@id": "urn:ex:s130", "urn:ex:p": "g/"},
          {"@id": "urn:ex:s131", "urn:ex:p": "/g"},
          {"@id": "urn:ex:s132", "urn:ex:p": "//g"},
          {"@id": "urn:ex:s133", "urn:ex:p": "?y"},
          {"@id": "urn:ex:s134", "urn:ex:p": "g?y"},
          {"@id": "urn:ex:s135", "urn:ex:p": "#s"},
          {"@id": "urn:ex:s136", "urn:ex:p": "g#s"},
          {"@id": "urn:ex:s137", "urn:ex:p": "g?y#s"},
          {"@id": "urn:ex:s138", "urn:ex:p": ";x"},
          {"@id": "urn:ex:s139", "urn:ex:p": "g;x"},
          {"@id": "urn:ex:s140", "urn:ex:p": "g;x?y#s"},
          {"@id": "urn:ex:s141", "urn:ex:p": ""},
          {"@id": "urn:ex:s142", "urn:ex:p": "."},
          {"@id": "urn:ex:s143", "urn:ex:p": "./"},
          {"@id": "urn:ex:s144", "urn:ex:p": ".."},
          {"@id": "urn:ex:s145", "urn:ex:p": "../"},
          {"@id": "urn:ex:s146", "urn:ex:p": "../g"},
          {"@id": "urn:ex:s147", "urn:ex:p": "../.."},
          {"@id": "urn:ex:s148", "urn:ex:p": "../../"},
          {"@id": "urn:ex:s149", "urn:ex:p": "../../g"}
        ]
      },
      {
        "@context": {"@base": "http://a/bb/ccc/../d;p?q", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s150", "urn:ex:p": "../../../g"},
          {"@id": "urn:ex:s151", "urn:ex:p": "../../../../g"},
          {"@id": "urn:ex:s152", "urn:ex:p": "/./g"},
          {"@id": "urn:ex:s153", "urn:ex:p": "/../g"},
          {"@id": "urn:ex:s154", "urn:ex:p": "g."},
          {"@id": "urn:ex:s155", "urn:ex:p": ".g"},
          {"@id": "urn:ex:s156", "urn:ex:p": "g.."},
          {"@id": "urn:ex:s157", "urn:ex:p": "..g"},
          {"@id": "urn:ex:s158", "urn:ex:p": "./../g"},
          {"@id": "urn:ex:s159", "urn:ex:p": "./g/."},
          {"@id": "urn:ex:s160", "urn:ex:p": "g/./h"},
          {"@id": "urn:ex:s161", "urn:ex:p": "g/../h"},
          {"@id": "urn:ex:s162", "urn:ex:p": "g;x=1/./y"},
          {"@id": "urn:ex:s163", "urn:ex:p": "g;x=1/../y"},
          {"@id": "urn:ex:s164", "urn:ex:p": "g?y/./x"},
          {"@id": "urn:ex:s165", "urn:ex:p": "g?y/../x"},
          {"@id": "urn:ex:s166", "urn:ex:p": "g#s/./x"},
          {"@id": "urn:ex:s167", "urn:ex:p": "g#s/../x"},
          {"@id": "urn:ex:s168", "urn:ex:p": "http:g"}
        ]
      },
      {
        "@context": {"@base": "http://a/bb/ccc/.", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s169", "urn:ex:p": "g:h"},
          {"@id": "urn:ex:s170", "urn:ex:p": "g"},
          {"@id": "urn:ex:s171", "urn:ex:p": "./g"},
          {"@id": "urn:ex:s172", "urn:ex:p": "g/"},
          {"@id": "urn:ex:s173", "urn:ex:p": "/g"},
          {"@id": "urn:ex:s174", "urn:ex:p": "//g"},
          {"@id": "urn:ex:s175", "urn:ex:p": "?y"},
          {"@id": "urn:ex:s176", "urn:ex:p": "g?y"},
          {"@id": "urn:ex:s177", "urn:ex:p": "#s"},
          {"@id": "urn:ex:s178", "urn:ex:p": "g#s"},
          {"@id": "urn:ex:s179", "urn:ex:p": "g?y#s"},
          {"@id": "urn:ex:s180", "urn:ex:p": ";x"},
          {"@id": "urn:ex:s181", "urn:ex:p": "g;x"},
          {"@id": "urn:ex:s182", "urn:ex:p": "g;x?y#s"},
          {"@id": "urn:ex:s183", "urn:ex:p": ""},
          {"@id": "urn:ex:s184", "urn:ex:p": "."},
          {"@id": "urn:ex:s185", "urn:ex:p": "./"},
          {"@id": "urn:ex:s186", "urn:ex:p": ".."},
          {"@id": "urn:ex:s187", "urn:ex:p": "../"},
          {"@id": "urn:ex:s188", "urn:ex:p": "../g"},
          {"@id": "urn:ex:s189", "urn:ex:p": "../.."},
          {"@id": "urn:ex:s190", "urn:ex:p": "../../"},
          {"@id": "urn:ex:s191", "urn:ex:p": "../../g"}
        ]
      },
      {
        "@context": {"@base": "http://a/bb/ccc/.", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s192", "urn:ex:p": "../../../g"},
          {"@id": "urn:ex:s193", "urn:ex:p": "../../../../g"},
          {"@id": "urn:ex:s194", "urn:ex:p": "/./g"},
          {"@id": "urn:ex:s195", "urn:ex:p": "/../g"},
          {"@id": "urn:ex:s196", "urn:ex:p": "g."},
          {"@id": "urn:ex:s197", "urn:ex:p": ".g"},
          {"@id": "urn:ex:s198", "urn:ex:p": "g.."},
          {"@id": "urn:ex:s199", "urn:ex:p": "..g"},
          {"@id": "urn:ex:s200", "urn:ex:p": "./../g"},
          {"@id": "urn:ex:s201", "urn:ex:p": "./g/."},
          {"@id": "urn:ex:s202", "urn:ex:p": "g/./h"},
          {"@id": "urn:ex:s203", "urn:ex:p": "g/../h"},
          {"@id": "urn:ex:s204", "urn:ex:p": "g;x=1/./y"},
          {"@id": "urn:ex:s205", "urn:ex:p": "g;x=1/../y"},
          {"@id": "urn:ex:s206", "urn:ex:p": "g?y/./x"},
          {"@id": "urn:ex:s207", "urn:ex:p": "g?y/../x"},
          {"@id": "urn:ex:s208", "urn:ex:p": "g#s/./x"},
          {"@id": "urn:ex:s209", "urn:ex:p": "g#s/../x"},
          {"@id": "urn:ex:s210", "urn:ex:p": "http:g"}
        ]
      },
      {
        "@context": {"@base": "http://a/bb/ccc/..", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s211", "urn:ex:p": "g:h"},
          {"@id": "urn:ex:s212", "urn:ex:p": "g"},
          {"@id": "urn:ex:s213", "urn:ex:p": "./g"},
          {"@id": "urn:ex:s214", "urn:ex:p": "g/"},
          {"@id": "urn:ex:s215", "urn:ex:p": "/g"},
          {"@id": "urn:ex:s216", "urn:ex:p": "//g"},
          {"@id": "urn:ex:s217", "urn:ex:p": "?y"},
          {"@id": "urn:ex:s218", "urn:ex:p": "g?y"},
          {"@id": "urn:ex:s219", "urn:ex:p": "#s"},
          {"@id": "urn:ex:s220", "urn:ex:p": "g#s"},
          {"@id": "urn:ex:s221", "urn:ex:p": "g?y#s"},
          {"@id": "urn:ex:s222", "urn:ex:p": ";x"},
          {"@id": "urn:ex:s223", "urn:ex:p": "g;x"},
          {"@id": "urn:ex:s224", "urn:ex:p": "g;x?y#s"},
          {"@id": "urn:ex:s225", "urn:ex:p": ""},
          {"@id": "urn:ex:s226", "urn:ex:p": "."},
          {"@id": "urn:ex:s227", "urn:ex:p": "./"},
          {"@id": "urn:ex:s228", "urn:ex:p": ".."},
          {"@id": "urn:ex:s229", "urn:ex:p": "../"},
          {"@id": "urn:ex:s230", "urn:ex:p": "../g"},
          {"@id": "urn:ex:s231", "urn:ex:p": "../.."},
          {"@id": "urn:ex:s232", "urn:ex:p": "../../"},
          {"@id": "urn:ex:s233", "urn:ex:p": "../../g"}
        ]
      },
      {
        "@context": {"@base": "http://a/bb/ccc/..", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s234", "urn:ex:p": "../../../g"},
          {"@id": "urn:ex:s235", "urn:ex:p": "../../../../g"},
          {"@id": "urn:ex:s236", "urn:ex:p": "/./g"},
          {"@id": "urn:ex:s237", "urn:ex:p": "/../g"},
          {"@id": "urn:ex:s238", "urn:ex:p": "g."},
          {"@id": "urn:ex:s239", "urn:ex:p": ".g"},
          {"@id": "urn:ex:s240", "urn:ex:p": "g.."},
          {"@id": "urn:ex:s241", "urn:ex:p": "..g"},
          {"@id": "urn:ex:s242", "urn:ex:p": "./../g"},
          {"@id": "urn:ex:s243", "urn:ex:p": "./g/."},
          {"@id": "urn:ex:s244", "urn:ex:p": "g/./h"},
          {"@id": "urn:ex:s245", "urn:ex:p": "g/../h"},
          {"@id": "urn:ex:s246", "urn:ex:p": "g;x=1/./y"},
          {"@id": "urn:ex:s247", "urn:ex:p": "g;x=1/../y"},
          {"@id": "urn:ex:s248", "urn:ex:p": "g?y/./x"},
          {"@id": "urn:ex:s249", "urn:ex:p": "g?y/../x"},
          {"@id": "urn:ex:s250", "urn:ex:p": "g#s/./x"},
          {"@id": "urn:ex:s251", "urn:ex:p": "g#s/../x"},
          {"@id": "urn:ex:s252", "urn:ex:p": "http:g"}
        ]
      },
      {
        "@context": {"@base": "file:///a/bb/ccc/d;p?q", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s253", "urn:ex:p": "g:h"},
          {"@id": "urn:ex:s254", "urn:ex:p": "g"},
          {"@id": "urn:ex:s255", "urn:ex:p": "./g"},
          {"@id": "urn:ex:s256", "urn:ex:p": "g/"},
          {"@id": "urn:ex:s257", "urn:ex:p": "/g"},
          {"@id": "urn:ex:s258", "urn:ex:p": "//g"},
          {"@id": "urn:ex:s259", "urn:ex:p": "?y"},
          {"@id": "urn:ex:s260", "urn:ex:p": "g?y"},
          {"@id": "urn:ex:s261", "urn:ex:p": "#s"},
          {"@id": "urn:ex:s262", "urn:ex:p": "g#s"},
          {"@id": "urn:ex:s263", "urn:ex:p": "g?y#s"},
          {"@id": "urn:ex:s264", "urn:ex:p": ";x"},
          {"@id": "urn:ex:s265", "urn:ex:p": "g;x"},
          {"@id": "urn:ex:s266", "urn:ex:p": "g;x?y#s"},
          {"@id": "urn:ex:s267", "urn:ex:p": ""},
          {"@id": "urn:ex:s268", "urn:ex:p": "."},
          {"@id": "urn:ex:s269", "urn:ex:p": "./"},
          {"@id": "urn:ex:s270", "urn:ex:p": ".."},
          {"@id": "urn:ex:s271", "urn:ex:p": "../"},
          {"@id": "urn:ex:s272", "urn:ex:p": "../g"},
          {"@id": "urn:ex:s273", "urn:ex:p": "../.."},
          {"@id": "urn:ex:s274", "urn:ex:p": "../../"},
          {"@id": "urn:ex:s275", "urn:ex:p": "../../g"}
        ]
      },
      {
        "@context": {"@base": "file:///a/bb/ccc/d;p?q", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s276", "urn:ex:p": "../../../g"},
          {"@id": "urn:ex:s277", "urn:ex:p": "../../../../g"},
          {"@id": "urn:ex:s278", "urn:ex:p": "/./g"},
          {"@id": "urn:ex:s279", "urn:ex:p": "/../g"},
          {"@id": "urn:ex:s280", "urn:ex:p": "g."},
          {"@id": "urn:ex:s281", "urn:ex:p": ".g"},
          {"@id": "urn:ex:s282", "urn:ex:p": "g.."},
          {"@id": "urn:ex:s283", "urn:ex:p": "..g"},
          {"@id": "urn:ex:s284", "urn:ex:p": "./../g"},
          {"@id": "urn:ex:s285", "urn:ex:p": "./g/."},
          {"@id": "urn:ex:s286", "urn:ex:p": "g/./h"},
          {"@id": "urn:ex:s287", "urn:ex:p": "g/../h"},
          {"@id": "urn:ex:s288", "urn:ex:p": "g;x=1/./y"},
          {"@id": "urn:ex:s289", "urn:ex:p": "g;x=1/../y"},
          {"@id": "urn:ex:s290", "urn:ex:p": "g?y/./x"},
          {"@id": "urn:ex:s291", "urn:ex:p": "g?y/../x"},
          {"@id": "urn:ex:s292", "urn:ex:p": "g#s/./x"},
          {"@id": "urn:ex:s293", "urn:ex:p": "g#s/../x"},
          {"@id": "urn:ex:s294", "urn:ex:p": "http:g"}
        ]
      },
      {
        "@context": {"@base": "http://abc/def/ghi", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s295", "urn:ex:p": "."},
          {"@id": "urn:ex:s296", "urn:ex:p": ".?a=b"},
          {"@id": "urn:ex:s297", "urn:ex:p": ".#a=b"},
          {"@id": "urn:ex:s298", "urn:ex:p": ".."},
          {"@id": "urn:ex:s299", "urn:ex:p": "..?a=b"},
          {"@id": "urn:ex:s300", "urn:ex:p": "..#a=b"}
        ]
      },
      {
        "@context": {"@base": "http://ab//de//ghi", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s301", "urn:ex:p": "xyz"},
          {"@id": "urn:ex:s302", "urn:ex:p": "./xyz"},
          {"@id": "urn:ex:s303", "urn:ex:p": "../xyz"}
        ]
      },
      {
        "@context": {"@base": "http://abc/d:f/ghi", "urn:ex:p": {"@type": "@id"}},
        "@graph": [
          {"@id": "urn:ex:s304", "urn:ex:p": "xyz"},
          {"@id": "urn:ex:s305", "urn:ex:p": "./xyz"},
          {"@id": "urn:ex:s306", "urn:ex:p": "../xyz"}
        ]
      }
    ]}}
    let(:nt) {%q{
      # RFC3986 normal examples

      <urn:ex:s001> <urn:ex:p> <g:h>.
      <urn:ex:s002> <urn:ex:p> <http://a/bb/ccc/g>.
      <urn:ex:s003> <urn:ex:p> <http://a/bb/ccc/g>.
      <urn:ex:s004> <urn:ex:p> <http://a/bb/ccc/g/>.
      <urn:ex:s005> <urn:ex:p> <http://a/g>.
      <urn:ex:s006> <urn:ex:p> <http://g>.
      <urn:ex:s007> <urn:ex:p> <http://a/bb/ccc/d;p?y>.
      <urn:ex:s008> <urn:ex:p> <http://a/bb/ccc/g?y>.
      <urn:ex:s009> <urn:ex:p> <http://a/bb/ccc/d;p?q#s>.
      <urn:ex:s010> <urn:ex:p> <http://a/bb/ccc/g#s>.
      <urn:ex:s011> <urn:ex:p> <http://a/bb/ccc/g?y#s>.
      <urn:ex:s012> <urn:ex:p> <http://a/bb/ccc/;x>.
      <urn:ex:s013> <urn:ex:p> <http://a/bb/ccc/g;x>.
      <urn:ex:s014> <urn:ex:p> <http://a/bb/ccc/g;x?y#s>.
      <urn:ex:s015> <urn:ex:p> <http://a/bb/ccc/d;p?q>.
      <urn:ex:s016> <urn:ex:p> <http://a/bb/ccc/>.
      <urn:ex:s017> <urn:ex:p> <http://a/bb/ccc/>.
      <urn:ex:s018> <urn:ex:p> <http://a/bb/>.
      <urn:ex:s019> <urn:ex:p> <http://a/bb/>.
      <urn:ex:s020> <urn:ex:p> <http://a/bb/g>.
      <urn:ex:s021> <urn:ex:p> <http://a/>.
      <urn:ex:s022> <urn:ex:p> <http://a/>.
      <urn:ex:s023> <urn:ex:p> <http://a/g>.

      # RFC3986 abnormal examples

      <urn:ex:s024> <urn:ex:p> <http://a/g>.
      <urn:ex:s025> <urn:ex:p> <http://a/g>.
      <urn:ex:s026> <urn:ex:p> <http://a/g>.
      <urn:ex:s027> <urn:ex:p> <http://a/g>.
      <urn:ex:s028> <urn:ex:p> <http://a/bb/ccc/g.>.
      <urn:ex:s029> <urn:ex:p> <http://a/bb/ccc/.g>.
      <urn:ex:s030> <urn:ex:p> <http://a/bb/ccc/g..>.
      <urn:ex:s031> <urn:ex:p> <http://a/bb/ccc/..g>.
      <urn:ex:s032> <urn:ex:p> <http://a/bb/g>.
      <urn:ex:s033> <urn:ex:p> <http://a/bb/ccc/g/>.
      <urn:ex:s034> <urn:ex:p> <http://a/bb/ccc/g/h>.
      <urn:ex:s035> <urn:ex:p> <http://a/bb/ccc/h>.
      <urn:ex:s036> <urn:ex:p> <http://a/bb/ccc/g;x=1/y>.
      <urn:ex:s037> <urn:ex:p> <http://a/bb/ccc/y>.
      <urn:ex:s038> <urn:ex:p> <http://a/bb/ccc/g?y/./x>.
      <urn:ex:s039> <urn:ex:p> <http://a/bb/ccc/g?y/../x>.
      <urn:ex:s040> <urn:ex:p> <http://a/bb/ccc/g#s/./x>.
      <urn:ex:s041> <urn:ex:p> <http://a/bb/ccc/g#s/../x>.
      <urn:ex:s042> <urn:ex:p> <http:g>.

      # RFC3986 normal examples with trailing slash in base IRI

      <urn:ex:s043> <urn:ex:p> <g:h>.
      <urn:ex:s044> <urn:ex:p> <http://a/bb/ccc/d/g>.
      <urn:ex:s045> <urn:ex:p> <http://a/bb/ccc/d/g>.
      <urn:ex:s046> <urn:ex:p> <http://a/bb/ccc/d/g/>.
      <urn:ex:s047> <urn:ex:p> <http://a/g>.
      <urn:ex:s048> <urn:ex:p> <http://g>.
      <urn:ex:s049> <urn:ex:p> <http://a/bb/ccc/d/?y>.
      <urn:ex:s050> <urn:ex:p> <http://a/bb/ccc/d/g?y>.
      <urn:ex:s051> <urn:ex:p> <http://a/bb/ccc/d/#s>.
      <urn:ex:s052> <urn:ex:p> <http://a/bb/ccc/d/g#s>.
      <urn:ex:s053> <urn:ex:p> <http://a/bb/ccc/d/g?y#s>.
      <urn:ex:s054> <urn:ex:p> <http://a/bb/ccc/d/;x>.
      <urn:ex:s055> <urn:ex:p> <http://a/bb/ccc/d/g;x>.
      <urn:ex:s056> <urn:ex:p> <http://a/bb/ccc/d/g;x?y#s>.
      <urn:ex:s057> <urn:ex:p> <http://a/bb/ccc/d/>.
      <urn:ex:s058> <urn:ex:p> <http://a/bb/ccc/d/>.
      <urn:ex:s059> <urn:ex:p> <http://a/bb/ccc/d/>.
      <urn:ex:s060> <urn:ex:p> <http://a/bb/ccc/>.
      <urn:ex:s061> <urn:ex:p> <http://a/bb/ccc/>.
      <urn:ex:s062> <urn:ex:p> <http://a/bb/ccc/g>.
      <urn:ex:s063> <urn:ex:p> <http://a/bb/>.
      <urn:ex:s064> <urn:ex:p> <http://a/bb/>.
      <urn:ex:s065> <urn:ex:p> <http://a/bb/g>.

      # RFC3986 abnormal examples with trailing slash in base IRI

      <urn:ex:s066> <urn:ex:p> <http://a/g>.
      <urn:ex:s067> <urn:ex:p> <http://a/g>.
      <urn:ex:s068> <urn:ex:p> <http://a/g>.
      <urn:ex:s069> <urn:ex:p> <http://a/g>.
      <urn:ex:s070> <urn:ex:p> <http://a/bb/ccc/d/g.>.
      <urn:ex:s071> <urn:ex:p> <http://a/bb/ccc/d/.g>.
      <urn:ex:s072> <urn:ex:p> <http://a/bb/ccc/d/g..>.
      <urn:ex:s073> <urn:ex:p> <http://a/bb/ccc/d/..g>.
      <urn:ex:s074> <urn:ex:p> <http://a/bb/ccc/g>.
      <urn:ex:s075> <urn:ex:p> <http://a/bb/ccc/d/g/>.
      <urn:ex:s076> <urn:ex:p> <http://a/bb/ccc/d/g/h>.
      <urn:ex:s077> <urn:ex:p> <http://a/bb/ccc/d/h>.
      <urn:ex:s078> <urn:ex:p> <http://a/bb/ccc/d/g;x=1/y>.
      <urn:ex:s079> <urn:ex:p> <http://a/bb/ccc/d/y>.
      <urn:ex:s080> <urn:ex:p> <http://a/bb/ccc/d/g?y/./x>.
      <urn:ex:s081> <urn:ex:p> <http://a/bb/ccc/d/g?y/../x>.
      <urn:ex:s082> <urn:ex:p> <http://a/bb/ccc/d/g#s/./x>.
      <urn:ex:s083> <urn:ex:p> <http://a/bb/ccc/d/g#s/../x>.
      <urn:ex:s084> <urn:ex:p> <http:g>.

      # RFC3986 normal examples with /. in the base IRI

      <urn:ex:s085> <urn:ex:p> <g:h>.
      <urn:ex:s086> <urn:ex:p> <http://a/bb/ccc/g>.
      <urn:ex:s087> <urn:ex:p> <http://a/bb/ccc/g>.
      <urn:ex:s088> <urn:ex:p> <http://a/bb/ccc/g/>.
      <urn:ex:s089> <urn:ex:p> <http://a/g>.
      <urn:ex:s090> <urn:ex:p> <http://g>.
      <urn:ex:s091> <urn:ex:p> <http://a/bb/ccc/./d;p?y>.
      <urn:ex:s092> <urn:ex:p> <http://a/bb/ccc/g?y>.
      <urn:ex:s093> <urn:ex:p> <http://a/bb/ccc/./d;p?q#s>.
      <urn:ex:s094> <urn:ex:p> <http://a/bb/ccc/g#s>.
      <urn:ex:s095> <urn:ex:p> <http://a/bb/ccc/g?y#s>.
      <urn:ex:s096> <urn:ex:p> <http://a/bb/ccc/;x>.
      <urn:ex:s097> <urn:ex:p> <http://a/bb/ccc/g;x>.
      <urn:ex:s098> <urn:ex:p> <http://a/bb/ccc/g;x?y#s>.
      <urn:ex:s099> <urn:ex:p> <http://a/bb/ccc/./d;p?q>.
      <urn:ex:s100> <urn:ex:p> <http://a/bb/ccc/>.
      <urn:ex:s101> <urn:ex:p> <http://a/bb/ccc/>.
      <urn:ex:s102> <urn:ex:p> <http://a/bb/>.
      <urn:ex:s103> <urn:ex:p> <http://a/bb/>.
      <urn:ex:s104> <urn:ex:p> <http://a/bb/g>.
      <urn:ex:s105> <urn:ex:p> <http://a/>.
      <urn:ex:s106> <urn:ex:p> <http://a/>.
      <urn:ex:s107> <urn:ex:p> <http://a/g>.

      # RFC3986 abnormal examples with /. in the base IRI

      <urn:ex:s108> <urn:ex:p> <http://a/g>.
      <urn:ex:s109> <urn:ex:p> <http://a/g>.
      <urn:ex:s110> <urn:ex:p> <http://a/g>.
      <urn:ex:s111> <urn:ex:p> <http://a/g>.
      <urn:ex:s112> <urn:ex:p> <http://a/bb/ccc/g.>.
      <urn:ex:s113> <urn:ex:p> <http://a/bb/ccc/.g>.
      <urn:ex:s114> <urn:ex:p> <http://a/bb/ccc/g..>.
      <urn:ex:s115> <urn:ex:p> <http://a/bb/ccc/..g>.
      <urn:ex:s116> <urn:ex:p> <http://a/bb/g>.
      <urn:ex:s117> <urn:ex:p> <http://a/bb/ccc/g/>.
      <urn:ex:s118> <urn:ex:p> <http://a/bb/ccc/g/h>.
      <urn:ex:s119> <urn:ex:p> <http://a/bb/ccc/h>.
      <urn:ex:s120> <urn:ex:p> <http://a/bb/ccc/g;x=1/y>.
      <urn:ex:s121> <urn:ex:p> <http://a/bb/ccc/y>.
      <urn:ex:s122> <urn:ex:p> <http://a/bb/ccc/g?y/./x>.
      <urn:ex:s123> <urn:ex:p> <http://a/bb/ccc/g?y/../x>.
      <urn:ex:s124> <urn:ex:p> <http://a/bb/ccc/g#s/./x>.
      <urn:ex:s125> <urn:ex:p> <http://a/bb/ccc/g#s/../x>.
      <urn:ex:s126> <urn:ex:p> <http:g>.

      # RFC3986 normal examples with /.. in the base IRI

      <urn:ex:s127> <urn:ex:p> <g:h>.
      <urn:ex:s128> <urn:ex:p> <http://a/bb/g>.
      <urn:ex:s129> <urn:ex:p> <http://a/bb/g>.
      <urn:ex:s130> <urn:ex:p> <http://a/bb/g/>.
      <urn:ex:s131> <urn:ex:p> <http://a/g>.
      <urn:ex:s132> <urn:ex:p> <http://g>.
      <urn:ex:s133> <urn:ex:p> <http://a/bb/ccc/../d;p?y>.
      <urn:ex:s134> <urn:ex:p> <http://a/bb/g?y>.
      <urn:ex:s135> <urn:ex:p> <http://a/bb/ccc/../d;p?q#s>.
      <urn:ex:s136> <urn:ex:p> <http://a/bb/g#s>.
      <urn:ex:s137> <urn:ex:p> <http://a/bb/g?y#s>.
      <urn:ex:s138> <urn:ex:p> <http://a/bb/;x>.
      <urn:ex:s139> <urn:ex:p> <http://a/bb/g;x>.
      <urn:ex:s140> <urn:ex:p> <http://a/bb/g;x?y#s>.
      <urn:ex:s141> <urn:ex:p> <http://a/bb/ccc/../d;p?q>.
      <urn:ex:s142> <urn:ex:p> <http://a/bb/>.
      <urn:ex:s143> <urn:ex:p> <http://a/bb/>.
      <urn:ex:s144> <urn:ex:p> <http://a/>.
      <urn:ex:s145> <urn:ex:p> <http://a/>.
      <urn:ex:s146> <urn:ex:p> <http://a/g>.
      <urn:ex:s147> <urn:ex:p> <http://a/>.
      <urn:ex:s148> <urn:ex:p> <http://a/>.
      <urn:ex:s149> <urn:ex:p> <http://a/g>.

      # RFC3986 abnormal examples with /.. in the base IRI

      <urn:ex:s150> <urn:ex:p> <http://a/g>.
      <urn:ex:s151> <urn:ex:p> <http://a/g>.
      <urn:ex:s152> <urn:ex:p> <http://a/g>.
      <urn:ex:s153> <urn:ex:p> <http://a/g>.
      <urn:ex:s154> <urn:ex:p> <http://a/bb/g.>.
      <urn:ex:s155> <urn:ex:p> <http://a/bb/.g>.
      <urn:ex:s156> <urn:ex:p> <http://a/bb/g..>.
      <urn:ex:s157> <urn:ex:p> <http://a/bb/..g>.
      <urn:ex:s158> <urn:ex:p> <http://a/g>.
      <urn:ex:s159> <urn:ex:p> <http://a/bb/g/>.
      <urn:ex:s160> <urn:ex:p> <http://a/bb/g/h>.
      <urn:ex:s161> <urn:ex:p> <http://a/bb/h>.
      <urn:ex:s162> <urn:ex:p> <http://a/bb/g;x=1/y>.
      <urn:ex:s163> <urn:ex:p> <http://a/bb/y>.
      <urn:ex:s164> <urn:ex:p> <http://a/bb/g?y/./x>.
      <urn:ex:s165> <urn:ex:p> <http://a/bb/g?y/../x>.
      <urn:ex:s166> <urn:ex:p> <http://a/bb/g#s/./x>.
      <urn:ex:s167> <urn:ex:p> <http://a/bb/g#s/../x>.
      <urn:ex:s168> <urn:ex:p> <http:g>.

      # RFC3986 normal examples with trailing /. in the base IRI

      <urn:ex:s169> <urn:ex:p> <g:h>.
      <urn:ex:s170> <urn:ex:p> <http://a/bb/ccc/g>.
      <urn:ex:s171> <urn:ex:p> <http://a/bb/ccc/g>.
      <urn:ex:s172> <urn:ex:p> <http://a/bb/ccc/g/>.
      <urn:ex:s173> <urn:ex:p> <http://a/g>.
      <urn:ex:s174> <urn:ex:p> <http://g>.
      <urn:ex:s175> <urn:ex:p> <http://a/bb/ccc/.?y>.
      <urn:ex:s176> <urn:ex:p> <http://a/bb/ccc/g?y>.
      <urn:ex:s177> <urn:ex:p> <http://a/bb/ccc/.#s>.
      <urn:ex:s178> <urn:ex:p> <http://a/bb/ccc/g#s>.
      <urn:ex:s179> <urn:ex:p> <http://a/bb/ccc/g?y#s>.
      <urn:ex:s180> <urn:ex:p> <http://a/bb/ccc/;x>.
      <urn:ex:s181> <urn:ex:p> <http://a/bb/ccc/g;x>.
      <urn:ex:s182> <urn:ex:p> <http://a/bb/ccc/g;x?y#s>.
      <urn:ex:s183> <urn:ex:p> <http://a/bb/ccc/.>.
      <urn:ex:s184> <urn:ex:p> <http://a/bb/ccc/>.
      <urn:ex:s185> <urn:ex:p> <http://a/bb/ccc/>.
      <urn:ex:s186> <urn:ex:p> <http://a/bb/>.
      <urn:ex:s187> <urn:ex:p> <http://a/bb/>.
      <urn:ex:s188> <urn:ex:p> <http://a/bb/g>.
      <urn:ex:s189> <urn:ex:p> <http://a/>.
      <urn:ex:s190> <urn:ex:p> <http://a/>.
      <urn:ex:s191> <urn:ex:p> <http://a/g>.

      # RFC3986 abnormal examples with trailing /. in the base IRI

      <urn:ex:s192> <urn:ex:p> <http://a/g>.
      <urn:ex:s193> <urn:ex:p> <http://a/g>.
      <urn:ex:s194> <urn:ex:p> <http://a/g>.
      <urn:ex:s195> <urn:ex:p> <http://a/g>.
      <urn:ex:s196> <urn:ex:p> <http://a/bb/ccc/g.>.
      <urn:ex:s197> <urn:ex:p> <http://a/bb/ccc/.g>.
      <urn:ex:s198> <urn:ex:p> <http://a/bb/ccc/g..>.
      <urn:ex:s199> <urn:ex:p> <http://a/bb/ccc/..g>.
      <urn:ex:s200> <urn:ex:p> <http://a/bb/g>.
      <urn:ex:s201> <urn:ex:p> <http://a/bb/ccc/g/>.
      <urn:ex:s202> <urn:ex:p> <http://a/bb/ccc/g/h>.
      <urn:ex:s203> <urn:ex:p> <http://a/bb/ccc/h>.
      <urn:ex:s204> <urn:ex:p> <http://a/bb/ccc/g;x=1/y>.
      <urn:ex:s205> <urn:ex:p> <http://a/bb/ccc/y>.
      <urn:ex:s206> <urn:ex:p> <http://a/bb/ccc/g?y/./x>.
      <urn:ex:s207> <urn:ex:p> <http://a/bb/ccc/g?y/../x>.
      <urn:ex:s208> <urn:ex:p> <http://a/bb/ccc/g#s/./x>.
      <urn:ex:s209> <urn:ex:p> <http://a/bb/ccc/g#s/../x>.
      <urn:ex:s210> <urn:ex:p> <http:g>.

      # RFC3986 normal examples with trailing /.. in the base IRI

      <urn:ex:s211> <urn:ex:p> <g:h>.
      <urn:ex:s212> <urn:ex:p> <http://a/bb/ccc/g>.
      <urn:ex:s213> <urn:ex:p> <http://a/bb/ccc/g>.
      <urn:ex:s214> <urn:ex:p> <http://a/bb/ccc/g/>.
      <urn:ex:s215> <urn:ex:p> <http://a/g>.
      <urn:ex:s216> <urn:ex:p> <http://g>.
      <urn:ex:s217> <urn:ex:p> <http://a/bb/ccc/..?y>.
      <urn:ex:s218> <urn:ex:p> <http://a/bb/ccc/g?y>.
      <urn:ex:s219> <urn:ex:p> <http://a/bb/ccc/..#s>.
      <urn:ex:s220> <urn:ex:p> <http://a/bb/ccc/g#s>.
      <urn:ex:s221> <urn:ex:p> <http://a/bb/ccc/g?y#s>.
      <urn:ex:s222> <urn:ex:p> <http://a/bb/ccc/;x>.
      <urn:ex:s223> <urn:ex:p> <http://a/bb/ccc/g;x>.
      <urn:ex:s224> <urn:ex:p> <http://a/bb/ccc/g;x?y#s>.
      <urn:ex:s225> <urn:ex:p> <http://a/bb/ccc/..>.
      <urn:ex:s226> <urn:ex:p> <http://a/bb/ccc/>.
      <urn:ex:s227> <urn:ex:p> <http://a/bb/ccc/>.
      <urn:ex:s228> <urn:ex:p> <http://a/bb/>.
      <urn:ex:s229> <urn:ex:p> <http://a/bb/>.
      <urn:ex:s230> <urn:ex:p> <http://a/bb/g>.
      <urn:ex:s231> <urn:ex:p> <http://a/>.
      <urn:ex:s232> <urn:ex:p> <http://a/>.
      <urn:ex:s233> <urn:ex:p> <http://a/g>.

      # RFC3986 abnormal examples with trailing /.. in the base IRI

      <urn:ex:s234> <urn:ex:p> <http://a/g>.
      <urn:ex:s235> <urn:ex:p> <http://a/g>.
      <urn:ex:s236> <urn:ex:p> <http://a/g>.
      <urn:ex:s237> <urn:ex:p> <http://a/g>.
      <urn:ex:s238> <urn:ex:p> <http://a/bb/ccc/g.>.
      <urn:ex:s239> <urn:ex:p> <http://a/bb/ccc/.g>.
      <urn:ex:s240> <urn:ex:p> <http://a/bb/ccc/g..>.
      <urn:ex:s241> <urn:ex:p> <http://a/bb/ccc/..g>.
      <urn:ex:s242> <urn:ex:p> <http://a/bb/g>.
      <urn:ex:s243> <urn:ex:p> <http://a/bb/ccc/g/>.
      <urn:ex:s244> <urn:ex:p> <http://a/bb/ccc/g/h>.
      <urn:ex:s245> <urn:ex:p> <http://a/bb/ccc/h>.
      <urn:ex:s246> <urn:ex:p> <http://a/bb/ccc/g;x=1/y>.
      <urn:ex:s247> <urn:ex:p> <http://a/bb/ccc/y>.
      <urn:ex:s248> <urn:ex:p> <http://a/bb/ccc/g?y/./x>.
      <urn:ex:s249> <urn:ex:p> <http://a/bb/ccc/g?y/../x>.
      <urn:ex:s250> <urn:ex:p> <http://a/bb/ccc/g#s/./x>.
      <urn:ex:s251> <urn:ex:p> <http://a/bb/ccc/g#s/../x>.
      <urn:ex:s252> <urn:ex:p> <http:g>.

      # RFC3986 normal examples with file path

      <urn:ex:s253> <urn:ex:p> <g:h>.
      <urn:ex:s254> <urn:ex:p> <file:///a/bb/ccc/g>.
      <urn:ex:s255> <urn:ex:p> <file:///a/bb/ccc/g>.
      <urn:ex:s256> <urn:ex:p> <file:///a/bb/ccc/g/>.
      <urn:ex:s257> <urn:ex:p> <file:///g>.
      <urn:ex:s258> <urn:ex:p> <file://g>.
      <urn:ex:s259> <urn:ex:p> <file:///a/bb/ccc/d;p?y>.
      <urn:ex:s260> <urn:ex:p> <file:///a/bb/ccc/g?y>.
      <urn:ex:s261> <urn:ex:p> <file:///a/bb/ccc/d;p?q#s>.
      <urn:ex:s262> <urn:ex:p> <file:///a/bb/ccc/g#s>.
      <urn:ex:s263> <urn:ex:p> <file:///a/bb/ccc/g?y#s>.
      <urn:ex:s264> <urn:ex:p> <file:///a/bb/ccc/;x>.
      <urn:ex:s265> <urn:ex:p> <file:///a/bb/ccc/g;x>.
      <urn:ex:s266> <urn:ex:p> <file:///a/bb/ccc/g;x?y#s>.
      <urn:ex:s267> <urn:ex:p> <file:///a/bb/ccc/d;p?q>.
      <urn:ex:s268> <urn:ex:p> <file:///a/bb/ccc/>.
      <urn:ex:s269> <urn:ex:p> <file:///a/bb/ccc/>.
      <urn:ex:s270> <urn:ex:p> <file:///a/bb/>.
      <urn:ex:s271> <urn:ex:p> <file:///a/bb/>.
      <urn:ex:s272> <urn:ex:p> <file:///a/bb/g>.
      <urn:ex:s273> <urn:ex:p> <file:///a/>.
      <urn:ex:s274> <urn:ex:p> <file:///a/>.
      <urn:ex:s275> <urn:ex:p> <file:///a/g>.

      # RFC3986 abnormal examples with file path

      <urn:ex:s276> <urn:ex:p> <file:///g>.
      <urn:ex:s277> <urn:ex:p> <file:///g>.
      <urn:ex:s278> <urn:ex:p> <file:///g>.
      <urn:ex:s279> <urn:ex:p> <file:///g>.
      <urn:ex:s280> <urn:ex:p> <file:///a/bb/ccc/g.>.
      <urn:ex:s281> <urn:ex:p> <file:///a/bb/ccc/.g>.
      <urn:ex:s282> <urn:ex:p> <file:///a/bb/ccc/g..>.
      <urn:ex:s283> <urn:ex:p> <file:///a/bb/ccc/..g>.
      <urn:ex:s284> <urn:ex:p> <file:///a/bb/g>.
      <urn:ex:s285> <urn:ex:p> <file:///a/bb/ccc/g/>.
      <urn:ex:s286> <urn:ex:p> <file:///a/bb/ccc/g/h>.
      <urn:ex:s287> <urn:ex:p> <file:///a/bb/ccc/h>.
      <urn:ex:s288> <urn:ex:p> <file:///a/bb/ccc/g;x=1/y>.
      <urn:ex:s289> <urn:ex:p> <file:///a/bb/ccc/y>.
      <urn:ex:s290> <urn:ex:p> <file:///a/bb/ccc/g?y/./x>.
      <urn:ex:s291> <urn:ex:p> <file:///a/bb/ccc/g?y/../x>.
      <urn:ex:s292> <urn:ex:p> <file:///a/bb/ccc/g#s/./x>.
      <urn:ex:s293> <urn:ex:p> <file:///a/bb/ccc/g#s/../x>.
      <urn:ex:s294> <urn:ex:p> <http:g>.

      # additional cases

      <urn:ex:s295> <urn:ex:p> <http://abc/def/>.
      <urn:ex:s296> <urn:ex:p> <http://abc/def/?a=b>.
      <urn:ex:s297> <urn:ex:p> <http://abc/def/#a=b>.
      <urn:ex:s298> <urn:ex:p> <http://abc/>.
      <urn:ex:s299> <urn:ex:p> <http://abc/?a=b>.
      <urn:ex:s300> <urn:ex:p> <http://abc/#a=b>.

      <urn:ex:s301> <urn:ex:p> <http://ab//de//xyz>.
      <urn:ex:s302> <urn:ex:p> <http://ab//de//xyz>.
      <urn:ex:s303> <urn:ex:p> <http://ab//de/xyz>.

      <urn:ex:s304> <urn:ex:p> <http://abc/d:f/xyz>.
      <urn:ex:s305> <urn:ex:p> <http://abc/d:f/xyz>.
      <urn:ex:s306> <urn:ex:p> <http://abc/xyz>.
    }}
    it "produces equivalent triples" do
      nt_str = RDF::NTriples::Reader.new(nt).dump(:ntriples)
      json_str = JSON::LD::Reader.new(json).dump(:ntriples)
      expect(json_str).to eql(nt_str)
    end
  end
end
