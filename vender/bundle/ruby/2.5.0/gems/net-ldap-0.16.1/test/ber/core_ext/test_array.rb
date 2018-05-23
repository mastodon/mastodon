require_relative '../../test_helper'

class TestBERArrayExtension < Test::Unit::TestCase
  def test_control_code_array
    control_codes = []
    control_codes << ['1.2.3'.to_ber, true.to_ber].to_ber_sequence
    control_codes << ['1.7.9'.to_ber, false.to_ber].to_ber_sequence
    control_codes = control_codes.to_ber_sequence
    res = [['1.2.3', true], ['1.7.9', false]].to_ber_control
    assert_equal control_codes, res
  end

  def test_wrap_array_if_not_nested
    result1 = ['1.2.3', true].to_ber_control
    result2 = [['1.2.3', true]].to_ber_control
    assert_equal result2, result1
  end

  def test_empty_string_if_empty_array
    assert_equal "", [].to_ber_control
  end
end
