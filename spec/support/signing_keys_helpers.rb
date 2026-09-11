# frozen_string_literal: true

module SigningKeysHelpers
  PUBLIC_RSA_TEST_KEY = <<~RSA
    -----BEGIN PUBLIC KEY-----
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuD7++C+IYBzC96Na27S5
    qqJhE6OSAe3/1r/hhGlvCl5a415Ma+wDDyHp8LcRI9fLcuyo+Hc0DNiBmjlNc9Oa
    TDlhfx917cYV7bHbw3yT0OcwcavsgnZBd3GRVaMgY0thAuLtw7XgMnRy4i2steUJ
    +anbsiC7F65gWsgvsD4W8Dk3Bmf5r+oDtgfo19t0NPsNM+pXtL1IKbBwnnyzkcO/
    f2kbSVvHgX7A9X33jca4Kgn1yyw/y5lYANKwi+Um8eEYXPVqWeYGc0/k8ZvcYS6B
    w0XWHLG9kjQU/ApoKlaLshmU46sCDKkJKw0p58urOV9vtwaAbx+0NK9GaU7C5QSa
    vQIDAQAB
    -----END PUBLIC KEY-----
  RSA

  PRIVATE_RSA_TEST_KEY = <<~RSA
    -----BEGIN RSA PRIVATE KEY-----
    MIIEpQIBAAKCAQEAuD7++C+IYBzC96Na27S5qqJhE6OSAe3/1r/hhGlvCl5a415M
    a+wDDyHp8LcRI9fLcuyo+Hc0DNiBmjlNc9OaTDlhfx917cYV7bHbw3yT0Ocwcavs
    gnZBd3GRVaMgY0thAuLtw7XgMnRy4i2steUJ+anbsiC7F65gWsgvsD4W8Dk3Bmf5
    r+oDtgfo19t0NPsNM+pXtL1IKbBwnnyzkcO/f2kbSVvHgX7A9X33jca4Kgn1yyw/
    y5lYANKwi+Um8eEYXPVqWeYGc0/k8ZvcYS6Bw0XWHLG9kjQU/ApoKlaLshmU46sC
    DKkJKw0p58urOV9vtwaAbx+0NK9GaU7C5QSavQIDAQABAoIBABxnIbky4qwmYuv4
    E86g2qpyY9K6OYzwmqsJY4OdGVAY4ZwBcniEpqgTi1PfdNX4s1VhJF9BSRXd3oTe
    5pC/gx7TDbOiLvTbv4+oBn/pWYQvz6kGXuxxvH/kUwpHnnuQKEFgqFSuWgSNLRSv
    A9v6lgIV7FdWcmEhMZttFuTtfW3EsTtL6Agjj6pNpREdgDQ4vu8LIMpTW9OOxee7
    Ui5oNSc+HNxsEo+Tb0pqfTuD6iztRIxLfBRS8M4EK9UTO82H4qYMb9HI6XfBshQ7
    3hhh9tDvo2QgX4L4FW8z64kmNli4MdhG+HDC2HWqX+f/4GxZUsUPWTkUVCS/nw2O
    JqYW+cECgYEA3ktP58HFbx3zfK1MdB2GjhyTMQqiP4VH50qj0VWvqEFdcP6nlMj4
    mhSwIhJJ2rzlclV0e5TAcHrWDx20Bpo72YfFORqMVIwXO5ZV9z3Xc83fu3KjUscv
    5UAghznN2Qc4CsxEI/I8/LMpLP2aua6RQPfQYk8LcdrafK7WBdkkF80CgYEA1C7J
    1xeIJHJxiLQ8g4g3BSPOP6MiM2qlQyapegWw7NA+sgG0MtTAddaZFkYrtkGZVvNF
    lFQQCe9SWzW1pwZxHlmOm95PC9B89E+kzoEEUU/scXtP04krp4eUXbuBfTQ0aLU+
    QZ3FsUkedLVJ8UH8zanY/VnjhtCgXdsT6Mz+vrECgYEAiBs2xqE3QMzm67y0Jhh5
    7YODgDCRnTD/EJf76816KxwymV/ivc+7n6PxIDtwavTjy/iUxKIUngooDMNUGgLP
    iGaAFHGz4ISSKRLoeeSsiaRRS9VqOOHq6oQ0Jnf3GN45qyrcweGtA9Cy8nApD23a
    VBwnxDm/uSuWQWdPde85ETUCgYEAycEjky6A+YcIhaA72iXviyecuc34e0NwmQVu
    KOS4crUgqEoOejbqOiIvtopKjiaaE5+GDaBRD+FMQgY0D/mEHgOyImukZet8pSIF
    54WuAVMp1E4YfV/07ntwjB/65H57RwTviZznmceY+ghXotvH8hcKiPyr6Ej/876Y
    k8g4gkECgYEAvN2GfwrLOgYaS3M0uldpOCHqod9zFABmzlmGn6+VLVkskFAA/RiC
    NO+Pm38bh3FbxBhLXM4sTGHn157/WCvaCSUSsjGJCkOemhXOJ+zEvo6yqANrtGMt
    f5zmr3d79JfG+WJbzZj7eO6LNbf2RHQKtuTLYNl0vmRpIcMaYJ8deNo=
    -----END RSA PRIVATE KEY-----
  RSA

  # Keypairs for remote actors typically do not include their private keys,
  # but we need to sign requests in tests. So use the known test private key
  # for known test public keys when testing.
  def private_key_from_keypair(keypair)
    case keypair.public_key
    when PUBLIC_RSA_TEST_KEY
      OpenSSL::PKey.read(PRIVATE_RSA_TEST_KEY)
    else
      OpenSSL::PKey.read(keypair.private_key)
    end
  end
end
