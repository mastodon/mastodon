require "test_helper"

class ManifestTest < Minitest::Test
  def test_lookup_exception!
    manifest_path = File.expand_path File.join(File.dirname(__FILE__), "test_app/public/packs", "manifest.json").to_s
    asset_file = "calendar.js"

    Webpacker.config.stub :compile?, false do
      error = assert_raises Webpacker::Manifest::MissingEntryError do
        Webpacker.manifest.lookup!(asset_file)
      end

      assert_match "Webpacker can't find #{asset_file} in #{manifest_path}", error.message
    end
  end

  def test_lookup_success!
    assert_equal Webpacker.manifest.lookup!("bootstrap.js"), "/packs/bootstrap-300631c4f0e0f9c865bc.js"
  end

  def test_lookup_nil
    assert_nil Webpacker.manifest.lookup("foo.js")
  end

  def test_lookup_success
    assert_equal Webpacker.manifest.lookup("bootstrap.js"), "/packs/bootstrap-300631c4f0e0f9c865bc.js"
  end
end
