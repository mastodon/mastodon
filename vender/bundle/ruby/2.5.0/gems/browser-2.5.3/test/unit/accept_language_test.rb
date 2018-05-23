# frozen_string_literal: true

require "test_helper"

class AcceptLanguageTest < Minitest::Test
  def assert_language(item, expect = {})
    assert_equal expect[:code], item.code, "failed code comparison"

    if expect[:region]
      assert_equal expect[:region], item.region, "failed region comparison"
    else
      assert_nil item.region,
                 "region should be nil; got #{item.region.inspect} instead"
    end

    assert_equal expect[:quality], item.quality, "failed quality comparison"
  end

  test "returns full language" do
    language = Browser::AcceptLanguage.new("en-GB")
    assert_equal "en-GB", language.full
  end

  test "returns language name" do
    language = Browser::AcceptLanguage.new("en-GB")
    assert_equal "English/United Kingdom", language.name

    language = Browser::AcceptLanguage.new("en")
    assert_equal "English", language.name
  end

  test "returns nil for unknown languages" do
    language = Browser::AcceptLanguage.new("unknown")
    assert_nil language.name
  end

  test "returns code" do
    language = Browser::AcceptLanguage.new("en-GB")
    assert_equal "en", language.code
  end

  test "returns formatted code" do
    %w[EN-GB En-GB eN-GB].each do |locale|
      language = Browser::AcceptLanguage.new(locale)
      assert_equal "en", language.code
    end
  end

  test "returns region" do
    language = Browser::AcceptLanguage.new("en-GB")
    assert_equal "GB", language.region
  end

  test "returns formatted region" do
    %w[en-gb en-Gb en-gB].each do |locale|
      language = Browser::AcceptLanguage.new(locale)
      assert_equal "GB", language.region
    end
  end

  test "returns nil for language without region" do
    language = Browser::AcceptLanguage.new("en")
    assert_nil language.region
  end

  test "parses language with quality" do
    language = Browser::AcceptLanguage.new("en-GB;q=0.8")
    assert_language language, code: "en", region: "GB", quality: 0.8
  end

  test "parses language without quality" do
    language = Browser::AcceptLanguage.new("en-GB")
    assert_language language, code: "en", region: "GB", quality: 1.0
  end

  test "parses language without region" do
    language = Browser::AcceptLanguage.new("en")
    assert_language language, code: "en", region: nil, quality: 1.0
  end

  test "ignores multi-part region" do
    language = Browser::AcceptLanguage.new("az-AZ-Cyrl")
    assert_language language, code: "az", region: "AZ", quality: 1.0
  end

  test "parses multi-language set" do
    result = Browser::AcceptLanguage.parse("fr-CA,fr;q=0.8")

    assert_equal 2, result.count
    assert_language result[0], code: "fr", region: "CA", quality: 1.0
    assert_language result[1], code: "fr", region: nil, quality: 0.8
  end

  test "parses wildcard" do
    result = Browser::AcceptLanguage.parse("fr-CA,*;q=0.8")

    assert_language result[0], code: "fr", region: "CA", quality: 1.0
    assert_language result[1], code: "*", region: nil, quality: 0.8
  end

  test "parses complex set" do
    accept_language = "fr-CA,fr;q=0.8,en-US;q=0.6,en;q=0.4,*;q=0.1"
    result = Browser::AcceptLanguage.parse(accept_language)

    assert_language result[0], code: "fr", region: "CA", quality: 1.0
    assert_language result[1], code: "fr", region: nil, quality: 0.8
    assert_language result[2], code: "en", region: "US", quality: 0.6
    assert_language result[3], code: "en", region: nil, quality: 0.4
    assert_language result[4], code: "*", region: nil, quality: 0.1
  end

  test "handles random white spaces" do
    accept_language = "fr-CA, fr;q=0.8,  en-US;q=0.6,en;q=0.4,    *;q=0.1"
    result = Browser::AcceptLanguage.parse(accept_language)

    assert_language result[0], code: "fr", region: "CA", quality: 1.0
    assert_language result[1], code: "fr", region: nil, quality: 0.8
    assert_language result[2], code: "en", region: "US", quality: 0.6
    assert_language result[3], code: "en", region: nil, quality: 0.4
    assert_language result[4], code: "*", region: nil, quality: 0.1
  end

  test "sorts based on quality" do
    accept_language = "fr-CA,fr;q=0.2,en-US;q=0.6,en;q=0.4,*;q=0.5"
    result = Browser::AcceptLanguage.parse(accept_language)

    assert_language result[0], code: "fr", region: "CA", quality: 1.0
    assert_language result[1], code: "en", region: "US", quality: 0.6
    assert_language result[2], code: "*", region: nil, quality: 0.5
    assert_language result[3], code: "en", region: nil, quality: 0.4
    assert_language result[4], code: "fr", region: nil, quality: 0.2
  end

  test "rejects quality values equals to zero (#241)" do
    result = Browser::AcceptLanguage.parse("de-DE,ru;q=0.9,de;q=0.8,en;q=0.")

    assert_equal 3, result.size
    assert_language result[0], code: "de", region: "DE", quality: 1.0
    assert_language result[1], code: "ru", region: nil, quality: 0.9
    assert_language result[2], code: "de", region: nil, quality: 0.8
  end

  test "handles invalid quality values that look like a number" do
    accept_language = "fr-CH, fr;q=0.9, en;q=0.8, de;q=0..7, *;q=0.5"
    result = Browser::AcceptLanguage.parse(accept_language)

    assert_equal 5, result.size
    assert_language result[3], code: "de", region: nil, quality: 0.7
  end
end
