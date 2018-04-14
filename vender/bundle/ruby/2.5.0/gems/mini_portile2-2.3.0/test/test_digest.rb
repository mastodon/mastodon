require File.expand_path('../helper', __FILE__)

class TestDigest < TestCase
  attr :assets_path, :tar_path, :recipe

  def before_all
    super
    @assets_path = File.expand_path("../assets", __FILE__)
    @tar_path = File.expand_path("../../tmp/test-digest-1.0.0.tar.gz", __FILE__)

    # remove any previous test files
    FileUtils.rm_rf("tmp")

    create_tar(@tar_path, @assets_path, "test mini portile-1.0.0")
    start_webrick(File.dirname(@tar_path))
  end

  def after_all
    super
    stop_webrick
    # leave test files for inspection
  end

  def setup
    super
    FileUtils.rm_rf("ports/archives")
    @recipe = MiniPortile.new("test-digest", "1.0.0")
  end

  def download_with_digest(key, klass)
    @recipe.files << {
      :url => "http://localhost:#{webrick.config[:Port]}/#{ERB::Util.url_encode(File.basename(tar_path))}",
      key => klass.file(tar_path).hexdigest,
    }
    @recipe.download
  end

  def download_with_wrong_digest(key)
    @recipe.files << {
      :url => "http://localhost:#{webrick.config[:Port]}/#{ERB::Util.url_encode(File.basename(tar_path))}",
      key => "0011223344556677",
    }
    assert_raises(RuntimeError){ @recipe.download }
  end

  def test_sha256
    download_with_digest(:sha256, Digest::SHA256)
  end

  def test_wrong_sha256
    download_with_wrong_digest(:sha256)
  end

  def test_sha1
    download_with_digest(:sha1, Digest::SHA1)
  end

  def test_wrong_sha1
    download_with_wrong_digest(:sha1)
  end

  def test_md5
    download_with_digest(:md5, Digest::MD5)
  end

  def test_wrong_md5
    download_with_wrong_digest(:md5)
  end

  def public_key
    <<-KEY
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mI0EVwUhJQEEAMYxFhgaAdM2Ul5r+XfpqAaI7SOxB14eRjhFjhchy4ylgVxetyLq
di3zeANXBIHsLBl7quYTlnmhJr/+GQRkCnXWiUp0tJsBVzGM3puK7c534gakEUH6
AlDtj5p3IeygzSyn8u7KORv+ainXfhwkvTO04mJmxAb2uT8ngKYFdPa1ABEBAAG0
J1Rlc3QgTWluaXBvcnRpbGUgPHRlc3RAbWluaXBvcnRpbGUub3JnPoi4BBMBAgAi
BQJXBSElAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRBl6D5JZMNwswAK
A/90Cdb+PX21weBR2Q6uR06M/alPexuXXyJL8ZcwbQMJ/pBBgcS5/h1+rQkBI/CN
qpXdDlw2Xys2k0sNwdjIw3hmYRzBrddXlCSW3Sifq/hS+kfPZ1snQmIjCgy1Xky5
QGCcPUxBUxzmra88LakkDO+euKK3hcrfeFIi611lTum1NLiNBFcFISUBBADoyY6z
2PwH3RWUbqv0VX1s3/JO3v3xMjCRKPlFwsNwLTBtZoWfR6Ao1ajeCuZKfzNKIQ2I
rn86Rcqyrq4hTj+7BTWjkIPOBthjiL1YqbEBtX7jcYRkYvdQz/IG2F4zVV6X4AAR
Twx7qaXNt67ArzbHCe5gLNRUK6e6OArkahMv7QARAQABiJ8EGAECAAkFAlcFISUC
GwwACgkQZeg+SWTDcLNFiwP/TR33ClqWOz0mpjt0xPEoZ0ORmV6fo4sjjzgQoHH/
KTdsabJbGp8oLQGW/mx3OxgbsAkyZymb5H5cjaF4HtSd4cxI5t1C9ZS/ytN8pqfR
e29SBje8DAAJn2l57s2OddXLPQ0DUwCcdNEaqgHwSk/Swxc7K+IpfvjLKHKUZZBP
4Ko=
=SVWi
-----END PGP PUBLIC KEY BLOCK-----
KEY
  end

  def test_with_valid_gpg_signature
    data_file = File.expand_path(File.join(File.dirname(__FILE__), 'assets', 'gpg-fixtures', 'data'))

    @recipe.files << {
      :url => "file://#{data_file}",
      :gpg => {
        :key => public_key,
        :signature_url => "file://#{data_file}.asc"
      }
    }
    @recipe.download
  end

  def test_optional_gpg_signature_url
    data_file = File.expand_path(File.join(File.dirname(__FILE__), 'assets', 'gpg-fixtures', 'data'))

    @recipe.files << {
      :url => "file://#{data_file}",
      :gpg => {
        :key => public_key
      }
    }
    @recipe.download
  end

  def test_with_invalid_gpg_signature
    data_file = File.expand_path(File.join(File.dirname(__FILE__), 'assets', 'gpg-fixtures', 'data'))

    @recipe.files << {
      :url => "file://#{data_file}",
      :gpg => {
        :key => public_key,
        :signature_url => "file://#{data_file}.invalid.asc"
      }
    }
    exception = assert_raises(RuntimeError){
      @recipe.download
    }
    assert_equal("signature mismatch", exception.message)
  end

  def test_with_invalid_key
    data_file = File.expand_path(File.join(File.dirname(__FILE__), 'assets', 'gpg-fixtures', 'data'))

    @recipe.files << {
      :url => "file://#{data_file}",
      :gpg => {
        :key => "thisisaninvalidkey",
        :signature_url => "file://#{data_file}.asc"
      }
    }
    exception = assert_raises(RuntimeError){ @recipe.download }
    assert_equal("invalid gpg key provided", exception.message)
  end

  def test_with_different_key_than_one_used_to_sign
    puts "################"

    key = <<-KEY
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

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
=4JAR
-----END PGP PUBLIC KEY BLOCK-----
KEY

    data_file = File.expand_path(File.join(File.dirname(__FILE__), 'assets', 'gpg-fixtures', 'data'))

    @recipe.files << {
      :url => "file://#{data_file}",
      :gpg => {
        :key => key,
        :signature_url => "file://#{data_file}.asc"
      }
    }
    exception = assert_raises(RuntimeError){ @recipe.download }
    assert_equal("signature mismatch", exception.message)
  end
end

