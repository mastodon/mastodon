# encoding: UTF-8
require 'helper'

describe ISO_639 do
  it "should have full code list in ISO_639_2" do
    assert_equal 485, ISO_639::ISO_639_2.length
  end

  it "should have shorter code list in ISO_639_1" do
    assert_equal 184, ISO_639::ISO_639_1.length
  end

  it "should return nil find_by_code when code does not exist or is invalid" do
    assert ISO_639.find_by_code(nil).nil?, 'nil code'
    assert ISO_639.find_by_code('xxx').nil?, 'xxx alfa-3 not existing code'
    assert ISO_639.find_by_code('xx').nil?, 'xx alfa-2 not existing code'
    assert ISO_639.find_by_code('xxxx').nil?, 'xxxx lengthy code'
    assert ISO_639.find_by_code('').nil?, 'empty string code'
  end

  it "should return entry for alpha-2 code" do
    assert_equal ["eng", "", "en", "English", "anglais"], ISO_639.find_by_code("en")
    assert_equal ["eng", "", "en", "English", "anglais"], ISO_639.find("en")
  end

  it "should return entry for alpha-3 terminologic code" do
    assert_equal ["ger", "deu", "de", "German", "allemand"], ISO_639.find("deu")
  end

  it "should find by english name" do
    assert_equal ["eng", "", "en", "English", "anglais"], ISO_639.find_by_english_name("English")
  end

  it "should find by french name" do
    assert_equal ["eng", "", "en", "English", "anglais"], ISO_639.find_by_french_name("anglais")
  end

  %w(
    alpha3_bibliographic
    alpha3
    alpha3_terminologic
    alpha2
    english_name
    french_name
  ).each_with_index do |m, i|
    it "should respond to and return #{m}" do
      @entry = ISO_639.find("en")
      assert @entry.respond_to?(m)
      assert_equal ["eng", "eng", "", "en", "English", "anglais"][i], @entry.send(m)
    end
  end

  it "should return single record array by searching a unique code" do
    assert_equal(
      [["spa", "", "es", "Spanish; Castilian", "espagnol; castillan"]],
      ISO_639.search("es")
    )
  end

  it "should return single record array by searching a unique term" do
    assert_equal(
      [["spa", "", "es", "Spanish; Castilian", "espagnol; castillan"]],
      ISO_639.search("spanish")
    )
  end

  it "should return multiple record array by searching a common term" do
    assert_equal(
      [
        ["egy", "", "", "Egyptian (Ancient)", "égyptien"],
        ["grc", "", "", "Greek, Ancient (to 1453)", "grec ancien (jusqu'à 1453)"]
      ],
      ISO_639.search("ancient")
    )
  end

  it "should return empty array when searching a non-existent term" do
    assert_equal(
      [], ISO_639.search("bad term")
    )
  end

  it "should return empty array when searching a nil term" do
    assert_equal [], ISO_639.search(nil)
  end

  it "should return single record array by searching a unique multi-word term" do
    assert_equal(
      [["ypk", "", "", "Yupik languages", "yupik, langues"]],
      ISO_639.search("yupik, langues")
    )
  end

  it "should error when attempting to change immutable ISO_639_2" do
    assert_raises RuntimeError do
      ISO_639::ISO_639_2 << ["test", "array"]
    end

    assert_raises RuntimeError do
      ISO_639::ISO_639_2[0] = []
    end

    assert_raises RuntimeError do
      ISO_639::ISO_639_2[0][1] = ""
    end

    assert_raises RuntimeError do
      ISO_639::ISO_639_2[0][1].upcase!
    end
  end

  it "should error when attempting to change immutable ISO_639_1" do
    assert_raises RuntimeError do
      ISO_639::ISO_639_1 << ["test", "array"]
    end

    assert_raises RuntimeError do
      ISO_639::ISO_639_1[0] = []
    end

    assert_raises RuntimeError do
      ISO_639::ISO_639_1[0][1] = ""
    end

    assert_raises RuntimeError do
      ISO_639::ISO_639_1[0][1].upcase!
    end
  end
end
