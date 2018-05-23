# frozen_string_literal: true

require "test_helper"

class EdgeTest < ActionController::TestCase
  test "detects Microsoft Edge" do
    browser = Browser.new(Browser["MS_EDGE"])

    assert_equal :edge, browser.id
    assert_equal "Microsoft Edge", browser.name
    assert_equal "12.0", browser.full_version
    assert_equal "12", browser.version
    assert browser.platform.windows10?
    assert browser.edge?
    assert browser.modern?
    refute browser.webkit?
    refute browser.chrome?
    refute browser.safari?
    refute browser.device.mobile?
  end

  test "detects Microsoft Edge in compatibility view" do
    browser = Browser.new(Browser["MS_EDGE_COMPAT"])

    assert_equal :edge, browser.id
    assert_equal "Microsoft Edge", browser.name
    assert_equal "12.0", browser.full_version
    assert_equal "12", browser.version
    assert_equal "7.0", browser.msie_full_version
    assert_equal "7", browser.msie_version
    assert browser.edge?
    assert browser.compatibility_view?
    refute browser.modern?
    refute browser.webkit?
    refute browser.chrome?
    refute browser.safari?
    refute browser.device.mobile?
  end

  test "detects Microsoft Edge Mobile" do
    browser = Browser.new(Browser["MS_EDGE_MOBILE"])

    assert_equal :edge, browser.id
    assert_equal "Microsoft Edge", browser.name
    assert_equal "12.0", browser.full_version
    assert_equal "12", browser.version
    refute browser.platform.windows10?
    assert browser.platform.windows_phone?
    assert browser.edge?
    assert browser.modern?
    refute browser.webkit?
    refute browser.chrome?
    refute browser.safari?
  end

  test "detects version by range" do
    browser = Browser.new(Browser["MS_EDGE"])
    assert browser.edge?(%w[>=12 <13])
  end
end
