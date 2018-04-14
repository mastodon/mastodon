require 'http_accept_language/parser'

describe HttpAcceptLanguage::Parser do

  def parser
    @parser ||= HttpAcceptLanguage::Parser.new('en-us,en-gb;q=0.8,en;q=0.6,es-419')
  end

  it "should return empty array" do
    parser.header = nil
    expect(parser.user_preferred_languages).to eq []
  end

  it "should properly split" do
    expect(parser.user_preferred_languages).to eq %w{en-US es-419 en-GB en}
  end

  it "should ignore jambled header" do
    parser.header = 'odkhjf89fioma098jq .,.,'
    expect(parser.user_preferred_languages).to eq []
  end

  it "should properly respect whitespace" do
    parser.header = 'en-us, en-gb; q=0.8,en;q = 0.6,es-419'
    expect(parser.user_preferred_languages).to eq %w{en-US es-419 en-GB en}
  end

  it "should find first available language" do
    expect(parser.preferred_language_from(%w{en en-GB})).to eq "en-GB"
  end

  it "should find first compatible language" do
    expect(parser.compatible_language_from(%w{en-hk})).to eq "en-hk"
    expect(parser.compatible_language_from(%w{en})).to eq "en"
  end

  it "should find first compatible from user preferred" do
    parser.header = 'en-us,de-de'
    expect(parser.compatible_language_from(%w{de en})).to eq 'en'
  end

  it "should accept symbols as available languages" do
    parser.header = 'en-us'
    expect(parser.compatible_language_from([:"en-HK"])).to eq :"en-HK"
  end

  it "should accept and ignore wildcards" do
    parser.header = 'en-US,en,*'
    expect(parser.compatible_language_from([:"en-US"])).to eq :"en-US"
  end

  it "should sanitize available language names" do
    expect(parser.sanitize_available_locales(%w{en_UK-x3 en-US-x1 ja_JP-x2 pt-BR-x5 es-419-x4})).to eq ["en-UK", "en-US", "ja-JP", "pt-BR", "es-419"]
  end

  it "should accept available language names as symbols and return them as strings" do
    expect(parser.sanitize_available_locales([:en, :"en-US", :ca, :"ca-ES"])).to eq ["en", "en-US", "ca", "ca-ES"]
  end

  it "should find most compatible language from user preferred" do
    parser.header = 'ja,en-gb,en-us,fr-fr'
    expect(parser.language_region_compatible_from(%w{en-UK en-US ja-JP})).to eq "ja-JP"
  end

end
