require_relative '../../test_helper'

class TestBERStringExtension < Test::Unit::TestCase
  def setup
    @bind_request = "0$\002\001\001`\037\002\001\003\004\rAdministrator\200\vad_is_bogus UNCONSUMED".b
    @result = @bind_request.read_ber!(Net::LDAP::AsnSyntax)
  end

  def test_parse_ber
    assert_equal [1, [3, "Administrator", "ad_is_bogus"]], @result
  end

  def test_unconsumed_message
    assert_equal " UNCONSUMED", @bind_request
  end

  def test_exception_does_not_modify_string
    original = "0$\002\001\001`\037\002\001\003\004\rAdministrator\200\vad_is_bogus".b
    duplicate = original.dup
    flexmock(StringIO).new_instances.should_receive(:read_ber).and_raise(Net::BER::BerError)
    duplicate.read_ber!(Net::LDAP::AsnSyntax) rescue Net::BER::BerError

    assert_equal original, duplicate
  end
end
