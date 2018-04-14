require 'test_helper'

class I18nBackendKeyValueTest < I18n::TestCase
  def setup_backend!(subtree=true)
    I18n.backend = I18n::Backend::KeyValue.new({}, subtree)
    store_translations(:en, :foo => { :bar => 'bar', :baz => 'baz' })
  end

  def assert_flattens(expected, nested, escape=true, subtree=true)
    assert_equal expected, I18n.backend.flatten_translations("en", nested, escape, subtree)
  end

  test "hash flattening works" do
    setup_backend!
    assert_flattens(
      {:a=>'a', :b=>{:c=>'c', :d=>'d', :f=>{:x=>'x'}}, :"b.f" => {:x=>"x"}, :"b.c"=>"c", :"b.f.x"=>"x", :"b.d"=>"d"},
      {:a=>'a', :b=>{:c=>'c', :d=>'d', :f=>{:x=>'x'}}}
    )
    assert_flattens({:a=>{:b =>['a', 'b']}, :"a.b"=>['a', 'b']}, {:a=>{:b =>['a', 'b']}})
    assert_flattens({:"a\001b" => "c"}, {:"a.b" => "c"})
    assert_flattens({:"a.b"=>['a', 'b']}, {:a=>{:b =>['a', 'b']}}, true, false)
    assert_flattens({:"a.b" => "c"}, {:"a.b" => "c"}, false)
  end

  test "store_translations handle subtrees by default" do
    setup_backend!
    assert_equal({ :bar => 'bar', :baz => 'baz' }, I18n.t("foo"))
  end

  test "store_translations merge subtrees accordingly" do
    setup_backend!
    store_translations(:en, :foo => { :baz => "BAZ"})
    assert_equal('BAZ', I18n.t("foo.baz"))
    assert_equal({ :bar => 'bar', :baz => 'BAZ' }, I18n.t("foo"))
  end

  test "store_translations does not handle subtrees if desired" do
    setup_backend!(false)
    assert_raise I18n::MissingTranslationData do
      I18n.t("foo", :raise => true)
    end
  end

  test "subtrees enabled: given incomplete pluralization data it raises I18n::InvalidPluralizationData" do
    setup_backend!
    store_translations(:en, :bar => { :one => "One" })
    assert_raise(I18n::InvalidPluralizationData) { I18n.t(:bar, :count => 2) }
  end

  test "subtrees disabled: given incomplete pluralization data it returns an error message" do
    setup_backend!(false)
    store_translations(:en, :bar => { :one => "One" })
    assert_equal "translation missing: en.bar", I18n.t(:bar, :count => 2)
  end

  test "translate handles subtrees for pluralization" do
    setup_backend!(false)
    store_translations(:en, :bar => { :one => "One" })
    assert_equal("One", I18n.t("bar", :count => 1))
  end
end if I18n::TestCase.key_value?
