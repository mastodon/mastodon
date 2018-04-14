# encoding: UTF-8
require_relative "./test_helper"

class HTMLEntities::ExpandedTest < Test::Unit::TestCase

  attr_reader :html_entities

  def setup
    @html_entities = HTMLEntities.new(:expanded)
  end

  TEST_ENTITIES_SET = [
    ['sub',      0x2282,   "xhtml", nil,      "⊂", ],
    ['sup',      0x2283,   "xhtml", nil,      "⊃", ],
    ['nsub',     0x2284,   "xhtml", nil,      "⊄", ],
    ['subE',     0x2286,   nil,     "skip",   "⊆", ],
    ['sube',     0x2286,   "xhtml", nil,      "⊆", ],
    ['supE',     0x2287,   nil,     "skip",   "⊇", ],
    ['supe',     0x2287,   "xhtml", nil,      "⊇", ],
    ['bottom',   0x22a5,   nil,     "skip",   "⊥", ],
    ['perp',     0x22a5,   "xhtml", nil,      "⊥", ],
    ['models',   0x22a7,   nil,     nil,      "⊧", ],
    ['vDash',    0x22a8,   nil,     nil,      "⊨", ],
    ['Vdash',    0x22a9,   nil,     nil,      "⊩", ],
    ['Vvdash',   0x22aa,   nil,     nil,      "⊪", ],
    ['nvdash',   0x22ac,   nil,     nil,      "⊬", ],
    ['nvDash',   0x22ad,   nil,     nil,      "⊭", ],
    ['nVdash',   0x22ae,   nil,     nil,      "⊮", ],
    ['nsubE',    0x2288,   nil,     nil,      "⊈", ],
    ['nsube',    0x2288,   nil,     "skip",   "⊈", ],
    ['nsupE',    0x2289,   nil,     nil,      "⊉", ],
    ['nsupe',    0x2289,   nil,     "skip",   "⊉", ],
    ['subnE',    0x228a,   nil,     nil,      "⊊", ],
    ['subne',    0x228a,   nil,     "skip",   "⊊", ],
    ['vsubnE',   0x228a,   nil,     "skip",   "⊊", ],
    ['vsubne',   0x228a,   nil,     "skip",   "⊊", ],
    ['nsc',      0x2281,   nil,     nil,      "⊁", ],
    ['nsup',     0x2285,   nil,     nil,      "⊅", ],
    ['b.alpha',  0x03b1,   nil,     "skip",   "α", ],
    ['b.beta',   0x03b2,   nil,     "skip",   "β", ],
    ['b.chi',    0x03c7,   nil,     "skip",   "χ", ],
    ['b.Delta',  0x0394,   nil,     "skip",   "Δ", ],
  ]

  def test_should_encode_apos_entity
    assert_equal "&apos;", html_entities.encode("'", :named) # note: the normal ' 0x0027, not ʼ 0x02BC
  end

  def test_should_decode_apos_entity
    assert_equal "é'", html_entities.decode("&eacute;&apos;")
  end

  def test_should_decode_dotted_entity
    assert_equal "Θ", html_entities.decode("&b.Theta;")
  end

  def test_should_encode_from_test_set
    TEST_ENTITIES_SET.each do |ent, _, _, skip, decoded|
      next if skip
      assert_equal "&#{ent};", html_entities.encode(decoded, :named)
    end
  end

  def test_should_decode_from_test_set
    TEST_ENTITIES_SET.each do |ent, _, _, _, decoded|
      assert_equal decoded, html_entities.decode("&#{ent};")
    end
  end

  def test_should_round_trip_preferred_entities
    TEST_ENTITIES_SET.each do |ent, _, _, skip, decoded|
      next if skip
      assert_equal "&#{ent};", html_entities.encode(html_entities.decode("&#{ent};"), :named)
      assert_equal decoded,    html_entities.decode(html_entities.encode(decoded, :named))
    end
  end

  def test_should_not_round_trip_decoding_skipped_entities
    TEST_ENTITIES_SET.each do |ent, _, _, skip, decoded|
      next unless skip
      assert_not_equal "&#{ent};", html_entities.encode(html_entities.decode("&#{ent};"), :named)
    end
  end

  def test_should_round_trip_encoding_skipped_entities
    TEST_ENTITIES_SET.each do |ent, _, _, skip, decoded|
      next unless skip
      assert_equal decoded,        html_entities.decode(html_entities.encode(decoded, :named))
    end
  end

  def test_should_treat_all_xhtml1_named_entities_as_xhtml_does
    xhtml_encoder = HTMLEntities.new(:xhtml1)
    HTMLEntities::MAPPINGS['xhtml1'].each do |ent, decoded|
      assert_equal xhtml_encoder.decode("&#{ent};"),      html_entities.decode("&#{ent};")
      assert_equal xhtml_encoder.encode(decoded, :named), html_entities.encode(decoded, :named)
    end
  end

  def test_should_not_agree_with_xhtml1_when_not_in_xhtml
    xhtml_encoder = HTMLEntities.new(:xhtml1)
    TEST_ENTITIES_SET.each do |ent, _, xhtml1, skip, decoded|
      next if xhtml1 || skip
      assert_not_equal xhtml_encoder.decode("&#{ent};"),         html_entities.decode("&#{ent};")
      assert_not_equal xhtml_encoder.encode(decoded, :named), html_entities.encode(decoded, :named)
    end
  end

end
