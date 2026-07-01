# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::ObjectIntegrityProof do
  describe '#verify_actor!' do
    # https://codeberg.org/fediverse/fep/src/branch/main/fep/8b32/fep-8b32.feature#L68

    let(:actor) { Fabricate(:account, username: 'alice', domain: 'server.example.org', uri: 'https://server.example/users/alice', public_key: '') }

    let(:json) do
      JSON.parse(<<~JSON)
        {
            "@context": [
                "https://www.w3.org/ns/activitystreams",
                "https://w3id.org/security/data-integrity/v2"
            ],
            "id": "https://server.example/activities/1",
            "type": "Create",
            "actor": "https://server.example/users/alice",
            "object": {
                "id": "https://server.example/objects/1",
                "type": "Note",
                "attributedTo": "https://server.example/users/alice",
                "content": "Hello world",
                "location": {
                    "type": "Place",
                    "longitude": -71.184902,
                    "latitude": 25.273962
                }
            },
            "proof": {
                "@context": [
                    "https://www.w3.org/ns/activitystreams",
                    "https://w3id.org/security/data-integrity/v2"
                ],
                "type": "DataIntegrityProof",
                "cryptosuite": "eddsa-jcs-2022",
                "verificationMethod": "https://server.example/users/alice#ed25519-key",
                "proofPurpose": "assertionMethod",
                "proofValue": "z42ffGu6AUKPCFcFPiabmUvnGLPJzC7e4DGWC52NUasSSH37UMa9c58tdgVszUcZfytxa4fQ5TYHaJENCxUDe9SdL",
                "created": "2023-02-24T23:36:38Z"
            }
        }
      JSON
    end

    context 'when the signature is correct' do
      before do
        _, pem = Multibase.decode_key_to_pem('z6MkrJVnaZkeFzdQyMZu1cgjg7k1pZZ6pvBQ7XJPt4swbTQ2')

        Fabricate(:keypair, account: actor, uri: 'https://server.example/users/alice#ed25519-key', type: :ed25519, public_key: pem)
      end

      it 'returns the actor' do
        expect(described_class.new(json).verify_actor!).to eq actor
      end
    end

    context 'when the signature is incorrect' do
      before do
        Fabricate(:keypair, account: actor, uri: 'https://server.example/users/alice#ed25519-key', type: :ed25519, public_key: OpenSSL::PKey.generate_key('Ed25519').public_to_pem)
      end

      it 'returns nil' do
        expect(described_class.new(json).verify_actor!).to be_nil
      end
    end

    context 'when the signature is correct and has an expiration date set in the future' do
      let(:json) do
        JSON.parse(<<~JSON)
          {
              "@context": [
                  "https://www.w3.org/ns/activitystreams",
                  "https://w3id.org/security/data-integrity/v2"
              ],
              "id": "https://server.example/activities/1",
              "type": "Create",
              "actor": "https://server.example/users/alice",
              "object": {
                  "id": "https://server.example/objects/1",
                  "type": "Note",
                  "attributedTo": "https://server.example/users/alice",
                  "content": "Hello world"
              },
              "proof": {
                  "@context": [
                      "https://www.w3.org/ns/activitystreams",
                      "https://w3id.org/security/data-integrity/v2"
                  ],
                  "type": "DataIntegrityProof",
                  "cryptosuite": "eddsa-jcs-2022",
                  "verificationMethod": "https://server.example/users/alice#ed25519-key",
                  "proofPurpose": "assertionMethod",
                  "proofValue": "z4bp44KNvTEeb7h8gY7tpbF9EaJxzbcYc6JNPxMv1wdWDakBt2vVEC3UzjctghA5XP2NevDnDCPzph2oNNb3qRJ8K",
                  "created": "2023-02-24T23:36:38Z",
                  "expires": "3000-01-01T00:00:00Z"
              }
          }
        JSON
      end

      before do
        _, pem = Multibase.decode_key_to_pem('z6MkrJVnaZkeFzdQyMZu1cgjg7k1pZZ6pvBQ7XJPt4swbTQ2')

        Fabricate(:keypair, account: actor, uri: 'https://server.example/users/alice#ed25519-key', type: :ed25519, public_key: pem)
      end

      it 'returns the actor' do
        expect(described_class.new(json).verify_actor!).to eq actor
      end
    end

    context 'when the signature is correct and has an expiration date set in the past' do
      let(:json) do
        JSON.parse(<<~JSON)
          {
              "@context": [
                  "https://www.w3.org/ns/activitystreams",
                  "https://w3id.org/security/data-integrity/v2"
              ],
              "id": "https://server.example/activities/1",
              "type": "Create",
              "actor": "https://server.example/users/alice",
              "object": {
                  "id": "https://server.example/objects/1",
                  "type": "Note",
                  "attributedTo": "https://server.example/users/alice",
                  "content": "Hello world"
              },
              "proof": {
                  "@context": [
                      "https://www.w3.org/ns/activitystreams",
                      "https://w3id.org/security/data-integrity/v2"
                  ],
                  "type": "DataIntegrityProof",
                  "cryptosuite": "eddsa-jcs-2022",
                  "verificationMethod": "https://server.example/users/alice#ed25519-key",
                  "proofPurpose": "assertionMethod",
                  "proofValue": "z25og1nNL6TLjQ8fHK4WmzWZzjb8BhcVvaoXToxE9qpcB6iqCWmWhmSAifmcWA11rtdomgGpkRNeEPDMXWJY5BDVQ",
                  "created": "2023-02-24T23:36:38Z",
                  "expires": "2023-02-24T23:36:39Z"
              }
          }
        JSON
      end

      before do
        _, pem = Multibase.decode_key_to_pem('z6MkrJVnaZkeFzdQyMZu1cgjg7k1pZZ6pvBQ7XJPt4swbTQ2')

        Fabricate(:keypair, account: actor, uri: 'https://server.example/users/alice#ed25519-key', type: :ed25519, public_key: pem)
      end

      it 'returns nil' do
        expect(described_class.new(json).verify_actor!).to be_nil
      end
    end
  end

  describe 'verify_eddsa_jcs_2022' do
    # https://www.w3.org/TR/vc-di-eddsa/#representation-eddsa-jcs-2022

    let(:keypair) do
      _, pem = Multibase.decode_key_to_pem('z6MkrJVnaZkeFzdQyMZu1cgjg7k1pZZ6pvBQ7XJPt4swbTQ2')

      OpenSSL::PKey.read(pem)
    end

    let(:secured_json) do
      JSON.parse(<<~JSON)
        {
          "@context": [
            "https://www.w3.org/ns/credentials/v2",
            "https://www.w3.org/ns/credentials/examples/v2"
          ],
          "id": "urn:uuid:58172aac-d8ba-11ed-83dd-0b3aef56cc33",
          "type": [
            "VerifiableCredential",
            "AlumniCredential"
          ],
          "name": "Alumni Credential",
          "description": "A minimum viable example of an Alumni Credential.",
          "issuer": "https://vc.example/issuers/5678",
          "validFrom": "2023-01-01T00:00:00Z",
          "credentialSubject": {
            "id": "did:example:abcdefgh",
            "alumniOf": "The School of Examples"
          },
          "proof": {
            "type": "DataIntegrityProof",
            "cryptosuite": "eddsa-jcs-2022",
            "created": "2023-02-24T23:36:38Z",
            "verificationMethod": "did:key:z6MkrJVnaZkeFzdQyMZu1cgjg7k1pZZ6pvBQ7XJPt4swbTQ2#z6MkrJVnaZkeFzdQyMZu1cgjg7k1pZZ6pvBQ7XJPt4swbTQ2",
            "proofPurpose": "assertionMethod",
            "@context": [
              "https://www.w3.org/ns/credentials/v2",
              "https://www.w3.org/ns/credentials/examples/v2"
            ],
            "proofValue": "z2HnFSSPPBzR36zdDgK8PbEHeXbR56YF24jwMpt3R1eHXQzJDMWS93FCzpvJpwTWd3GAVFuUfjoJdcnTMuVor51aX"
          }
        }
      JSON
    end

    context 'with a correct signature' do
      it 'verifies correctly' do
        expect(described_class.verify_eddsa_jcs_2022(secured_json, keypair)).to be true
      end
    end

    context 'with an incorrect signature' do
      let(:keypair) { OpenSSL::PKey.generate_key('ed25519') }

      it 'does not verify document' do
        expect(described_class.verify_eddsa_jcs_2022(secured_json, keypair)).to be false
      end
    end
  end

  describe 'verify_mldsa44_jcs_2024', skip: 'waiting for ubuntu-26.04 runners' do
    # https://www.w3.org/TR/2026/WD-vc-di-quantum-resistant-1.0-20260616/#example-signed-credential-mldsa44-jcs-2024

    let(:keypair) do
      _, pem = Multibase.decode_key_to_pem(
        'ukCRKDtY8Do_dXzYGyuX7BY-1dDYM4FuSiw0gFdO-eJXFH0eqlt4_CP4sEISGAzNlKDzLpUJWoInRywXOpd7FCp_QAJAlL7iRo4cepKhzhlq8xt6qd5jkhYF9tNH8z3RGDl9aunNy_06fWLYNScWd5RmGg46Po8T-kIjMMkJftaqqZcGDxktpu9Et2bnaZMx4K98YyG1urUpM9lgvldgg2qv-6XCrm2uXlJ9U-HN4xtQKn4Ug-5xPwbhPGR2pbcBScTFotkhBqLc2eQLL6zPutWF83sSZbOhD_11BjMkeiLyJbMeHCIhz5GDIbPksEFIaSho3MdFo5fpQ8QZoqCit3Jn4ddfuShfIoLU1Hw5EZ0xBiqOU7e-TINd7-7HsgHLmYMGnpqljm1ot3c3cfalYsg87WQuSscO7XNH3Ewa-cgU6Bnj1SGn0plTy6Yq-GxU8XUBPwsK_IoIJbXWC0UD97c9UYpNiZi0-ECnbB-Y5_SM8auMfoIeap_buAOdXlJZmcp8xNCXI59AN9-96Sdhks5L-JmsELzyjAgjqNx8Zt3KPFc2jSwNjDVC1fEa8FdDdDT3WNkF6KTt65lb5_aIkFh20nOvT7kIJcKTgmhRGNJZgGSPYVbMypaQoaac8dtEoQjvYgnO-rM_RcsiWMHNc29br3o5wdiLXdr63MoX1lEWu_THBfeP1JuxrSbUmHOByepWbubbSM4iVQITCxBHZT0Mj2bWwIxd3nZUajzebyEnsfitV01kpzlO7bzY2uxSzyplTkRfppc_7YH0y0PHaggw0cIXNSh73wVqNZmzmJx5W0_akrvy5oSz9ZB1Io2p_fTxzibefwO700bUqbElV_yuCjD7EJ_Hfqbog80y_g9TK6koX7wYwqFNQxBVavKC-HbcT7yPdvzs9hlC2MNWCT3W7gVgeYr4AFgbV9EgMcH0GtJDKYw8vkpB_vTsaSTGZAj3TNKalAwiGO50VAmF5tknF96kOrWmNL0MdkXhnm1vXgDpP68bMt4r2Qr-hNdJ4s3_nqmSDYTnZRA4qjXjrgKQfO19txt0tX7LifE1GZ1bQyS7NqHWXyMEhw6_F8pc_tS16VhvJO_FM7CX51mLLkLCGl7DsmbnEIsVUW9qlCxb6bj53UyijTYdu6uLZW9JISE2B4EevxzwDu9UGcJPHmJYi1rRQAP__jH97GiQC8FvkdAEfKqcwV9jAbBPQPG6lUkBLcoijgR3Bcwd-ta92oeZmcpoJ97PzzBbCL-NrppJ2HHQ1SMsYWoPveZTmZc66YBA0P9YfT4hZ0RQiP2gxB4snTvMFI0Ot6Q2nQ0p5DMxmWqIaCKW53rqn16AVXQeqC2TJjlbjA9sC6pr8GEGY2OQUgEmWu5GmnOSz1lNY7fNHJypChnieI_hyYiy06qouUpoHA5z_IUtfzZoMIG0yJiGUUpF9BJvYChDECCqaUM1kWnO5tKcohSKq5Hqwu_EWDRYF2tj7igSimZkS4Pts41tu8nIaVk5EkzAX9gCR2EX3Lk869mIxSyBS3MyG_NotPcbm6uXDn_YkV5Z0HkxUxYRA9hIG-UhKhK3VOaHZP8GcQN8noOMa2CnPd208X6HOzlIlxs7SRbzppUs_fHN1eROglNy-2oJWGmo-xOy0Qd44TtY0S_bYhu6iH6inrx3-yncSrWFxEiYosvYJD4ZBSyrV4d6UsfeNSHYS0ODTsdPqz4SYTeloZbIx8XWz7fxLXlNyLr3s9tp-Q25f1vTIrmQL' # rubocop:disable Layout/LineLength
      )

      OpenSSL::PKey.read(pem)
    end

    let(:secured_json) do
      JSON.parse(<<~JSON)
        {
          "@context": [
            "https://www.w3.org/ns/credentials/v2",
            "https://w3id.org/citizenship/v4rc1"
          ],
          "type": [
            "VerifiableCredential",
            "EmploymentAuthorizationDocumentCredential"
          ],
          "issuer": {
            "id": "did:key:zDnaegE6RR3atJtHKwTRTWHsJ3kNHqFwv7n9YjTgmU7TyfU76",
            "image": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIW2NgUPr/HwADaAIhG61j/AAAAABJRU5ErkJggg=="
          },
          "credentialSubject": {
            "type": [
              "Person",
              "EmployablePerson"
            ],
            "givenName": "JOHN",
            "additionalName": "JACOB",
            "familyName": "SMITH",
            "image": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIW2Ng+M/wHwAEAQH/7yMK/gAAAABJRU5ErkJggg==",
            "gender": "Male",
            "residentSince": "2015-01-01",
            "birthCountry": "Bahamas",
            "birthDate": "1999-07-17",
            "employmentAuthorizationDocument": {
              "type": "EmploymentAuthorizationDocument",
              "identifier": "83627465",
              "lprCategory": "C09",
              "lprNumber": "999-999-999"
            }
          },
          "name": "Employment Authorization Document",
          "description": "Example Employment Authorization Document.",
          "validFrom": "2019-12-03T00:00:00Z",
          "validUntil": "2029-12-03T00:00:00Z",
          "proof": {
            "type": "DataIntegrityProof",
            "cryptosuite": "mldsa44-jcs-2024",
            "created": "2023-02-24T23:36:38Z",
            "verificationMethod": "did:key:ukCRKDtY8Do_dXzYGyuX7BY-1dDYM4FuSiw0gFdO-eJXFH0eqlt4_CP4sEISGAzNlKDzLpUJWoInRywXOpd7FCp_QAJAlL7iRo4cepKhzhlq8xt6qd5jkhYF9tNH8z3RGDl9aunNy_06fWLYNScWd5RmGg46Po8T-kIjMMkJftaqqZcGDxktpu9Et2bnaZMx4K98YyG1urUpM9lgvldgg2qv-6XCrm2uXlJ9U-HN4xtQKn4Ug-5xPwbhPGR2pbcBScTFotkhBqLc2eQLL6zPutWF83sSZbOhD_11BjMkeiLyJbMeHCIhz5GDIbPksEFIaSho3MdFo5fpQ8QZoqCit3Jn4ddfuShfIoLU1Hw5EZ0xBiqOU7e-TINd7-7HsgHLmYMGnpqljm1ot3c3cfalYsg87WQuSscO7XNH3Ewa-cgU6Bnj1SGn0plTy6Yq-GxU8XUBPwsK_IoIJbXWC0UD97c9UYpNiZi0-ECnbB-Y5_SM8auMfoIeap_buAOdXlJZmcp8xNCXI59AN9-96Sdhks5L-JmsELzyjAgjqNx8Zt3KPFc2jSwNjDVC1fEa8FdDdDT3WNkF6KTt65lb5_aIkFh20nOvT7kIJcKTgmhRGNJZgGSPYVbMypaQoaac8dtEoQjvYgnO-rM_RcsiWMHNc29br3o5wdiLXdr63MoX1lEWu_THBfeP1JuxrSbUmHOByepWbubbSM4iVQITCxBHZT0Mj2bWwIxd3nZUajzebyEnsfitV01kpzlO7bzY2uxSzyplTkRfppc_7YH0y0PHaggw0cIXNSh73wVqNZmzmJx5W0_akrvy5oSz9ZB1Io2p_fTxzibefwO700bUqbElV_yuCjD7EJ_Hfqbog80y_g9TK6koX7wYwqFNQxBVavKC-HbcT7yPdvzs9hlC2MNWCT3W7gVgeYr4AFgbV9EgMcH0GtJDKYw8vkpB_vTsaSTGZAj3TNKalAwiGO50VAmF5tknF96kOrWmNL0MdkXhnm1vXgDpP68bMt4r2Qr-hNdJ4s3_nqmSDYTnZRA4qjXjrgKQfO19txt0tX7LifE1GZ1bQyS7NqHWXyMEhw6_F8pc_tS16VhvJO_FM7CX51mLLkLCGl7DsmbnEIsVUW9qlCxb6bj53UyijTYdu6uLZW9JISE2B4EevxzwDu9UGcJPHmJYi1rRQAP__jH97GiQC8FvkdAEfKqcwV9jAbBPQPG6lUkBLcoijgR3Bcwd-ta92oeZmcpoJ97PzzBbCL-NrppJ2HHQ1SMsYWoPveZTmZc66YBA0P9YfT4hZ0RQiP2gxB4snTvMFI0Ot6Q2nQ0p5DMxmWqIaCKW53rqn16AVXQeqC2TJjlbjA9sC6pr8GEGY2OQUgEmWu5GmnOSz1lNY7fNHJypChnieI_hyYiy06qouUpoHA5z_IUtfzZoMIG0yJiGUUpF9BJvYChDECCqaUM1kWnO5tKcohSKq5Hqwu_EWDRYF2tj7igSimZkS4Pts41tu8nIaVk5EkzAX9gCR2EX3Lk869mIxSyBS3MyG_NotPcbm6uXDn_YkV5Z0HkxUxYRA9hIG-UhKhK3VOaHZP8GcQN8noOMa2CnPd208X6HOzlIlxs7SRbzppUs_fHN1eROglNy-2oJWGmo-xOy0Qd44TtY0S_bYhu6iH6inrx3-yncSrWFxEiYosvYJD4ZBSyrV4d6UsfeNSHYS0ODTsdPqz4SYTeloZbIx8XWz7fxLXlNyLr3s9tp-Q25f1vTIrmQL",
            "proofPurpose": "assertionMethod",
            "proofValue": "uTSucVLvXmOpmjGGNB-B9rM-u4HzBxN8ZIuZbpTHrjOTNBnahoE4PSdkeD-IzLLXykJn0aYq_APExy-Ka0BcJNMvKgkdjbbP33WmUwkzljno3szRUDrN9KX2DMH7j0iOBakU4ByjD-hTSO1iR6rlxsZPHJM1H-WLMhzVSggBILAuglItzstl663Gz5bFjEfbKAgfe50L4v4PjLFSDbJYcg65GtCKRXISkWrnJRuToWwvTVdcnIBOQwPBFKsvApPJMKrUTkIuZf4-V1uJ81zzct4o20O-DqLQ5bHfOR2n5Y4DSy6e5zg0-S3ADKtMtuPaQ8cAPUTEKRXGRQnSndnrtgMh2dimvpSaaw0TDy7zY6vrDxJa1tkrS0ulKf3Xz8xsNrNIkx4SaKYWPTjhRvdKqjdrpbGRt3mRSFFc0VE8vK44F_EVFIhwouL-4Rm4mXU2QkiO0YkwuAJM-QdWUACqzJ7TSf2QrrU8zAwOLbrGS5uZ1qLGD1PcgWfg2d0zTAYmcWP4LP63fTnFxwr-L0N_3MLFXixHNEp5osMlo2lhl5noDCmQpqCgluxkd5gXs1NSpOBbWVQyYWcj0WMBtMam8AeqXpA39L7oqvYxqbEpiwvKrmHsXIEZrnsHKCk2P0yc10AFCCtsIapvTHwIAjbDhX11HFU5cci4X5vCdG2BUzRsgmGeiYiUClCHmqsBW4z2GA9r0d9jtHZ03nMie_qS95XPsXuAFqypsP1HOfcIUAHHS9Wn4XGFz3hXoqMsmoUGRg9vEpC2j_nkcYZQphYLs54veWq5BBzoMqPuvYhhRdawdCnn-LTf7AxQgVGoRTpTy4IkXxr_pC1LUJZJkdKeG-2TuQzyHSkbMPu3YbWsGy2KxdGeFN2yUI8TTQ-MFHl-_jDCRBrAYyCVOgML4NAtbGqvs7h2tGZYI-m9MfjG0vjp7CUyIPD8BV-Yhku_bHd0hcrseKtYYyUjxISf2wveo4dfQ2AnCVdDAbBmznjPIDlkqx0316sRc-vXJGRQmfXOW1dNk-7WNBrJVQbnT9m6cf0UEl3mEgagk1_lLOxTgjzZRpWcOB827VB3hPi7RdI6U6knXuOflHPt9BZN7i6OAl76k69uMFH2KNH3Abm0GDhOv_nu1lEaOH8aXdOqL3U8Yo0cp5roOoTw5fJP2gxwI3DY0TOWeNOCfLXmnodgoGaKG2Vns4_-gN_Mg7g0ZinguwJMwKACx07H__ffh8jYQdc87EjCNyH4m8hJICvcC81J7CKb89YTZm7IM0D1_qTR5t-DkuU4ypxNuFOCxWpN9y2QiLAAobDdc1Y_S3nXFFkLmsn7hUNhcgXxPC3jLifiM0IV7DAqmQpk2ZGE59l0VTKb3F2Ualj9JcqKtLg_b2KqprUol9WtjFlkbxqJPYyCKnSEitzDnDsfxTRFEIViTx5-1SFb0NjPE_hv5MewCkizNpfo0b-m-FxvyWJnDYt4Igv8JtgF0K_xMRC9Tf3NaQgFHb1OgkBz04C3wsxoPLqTgMWoxcZ2-2x7TRRvX2Nh1Ye-ZrpmF5hVeRMK0ECj_t5HLPaq2md18rqnhwsZv84-V0eReDyXVIhkE2eAKedCM9t13UjTfF1qFoUQ3D8xQ6MfR7zFwf6X78Tb0EFs0cBQ1TatzWysbE2b_0k-YbT78G4Ko8FlmTljBN1b0StKxzOE1Kp1h4nDBY9jZYYPNnVrtAGn2AKN3HWr0bhhF8fW_G4SA_MGu2r6LnobB3MLCSj1lbVZSk5YtCtMnkldAsDagoI8lRBlKW1R7PFvXatSHcwbe352nVuvZYxs9QJVSylf2QS1xeUQUMS4AHd4h8Y9HqmnGPr5JX65uch8sr1bWcpGiNlwnMlFy89pnEZU2v7IiC_foLi8JbxMud1k2XRDwThhepEf5bxqlBcgjF8vAbGEKAJg5Oahl0GCBffuHhuUXmuF6XwOxLovlJUM8oFCTayQL42NGz_Z2cuFltmiy-cbI8NmEpvlOPnGZBj00ZIrp9tAgwepYvlt5ticFn9ufU-f8xZpBpZb-rf5sVTNqYmoOYvhKVhE5cCPpCbzZ5GvW5ukB8yLLJC5sc6df9oSoujovfA_VAXqsvmBuKU4cHcNTNEqzsGEg_l0ln5FIHKH3CRUTDemKN2vbtmTz1snn4VfdBFAlhJhBItpBmd3HibH-1q2WD313j-cE5nW_QgQeDn_JFJ7zwlORQVRUkeB942HJjkHWXCJMXz9LKxdncKalaVNm-yVjDkQdgA1tKl9bc_QnAL7HWhtHFc_XhzJvQxqLJ0aLUkkrnphrqscG6D_Kdh7aTTkDjDSA-dmgRQBh51YVBnfnp5V28AwmGXXglBAWCWChGmAtac6xeLbxW143426J4HMAUIpLgNhjetQoQqKzVTIpzcyo-GK8L3C0calt57orTswSRqDjxg_6zAQ6RPNoThToRqb2QgHr-gOop6NEJkEy0K8GwPg3nYAFgVVjcCyDtMEbIrHXJ9WKg3oTd14eC7GNZgQ75aP3HpUAqT5gqWdxer35Ohs3n1FylwreS1kOZ5Z4OVW5PVJkNHhKPfaNq4mQT5vBAWlWphOotPHwTbN7oMiOGYu-AMTnsLPCn0A3VEXx16EROpu0zlVisEZo1sya8nQaJYiI_i3MEWqvV2ypvcMDYt_ArFjxMU3tjV5tNcJgIoE5E5UCGyo2HQMvN03T0GdHZr7txswg9HpRJqntiJzm0iAr9BhRPfErg4HLQyc92gOH6UdczP4hvbweP3mcW67yUT3lH31vznZ5lIJ0pth3H_7khwUff5daIROar2usWxoMWTItY5HC7v5HBjnfqj4EoVi1A4Uw7RvHhaCMkfDrqqntNM0TDDSfDP1uCB1RwZtcuWpNfLWYyP1B9XqwKg3EworHhIq1vI74gZROvebyYqx8UCFeiLubTfXHJrC2evT99ha6jf7vg8zKgew6Cj3Jz_RSRE5rF5uQQno6PsevbKKtZsQmn0PQphfNzWqacMpred2yrmetGOEG_JvYxx5Scmu8w8Yg-3V7yhMeDsOh0DZ8sjTw5d-w3zKUNeU2IZzz5wvaJ7-8RRxyJqxFsUFaBv7WxUZ0bmWg4pRXdBUKNW53mEUGDigpRF6Fla-6wc4BCDhwfJWdpaixu8Lf4fkRKCs0Y4-lrsTH1-zwNkKBudbd6v4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwbKDA"
          }
        }
      JSON
    end

    context 'with a correct signature' do
      it 'verifies correctly' do
        expect(described_class.verify_mldsa44_jcs_2024(secured_json, keypair)).to be true
      end
    end

    context 'with an incorrect signature' do
      let(:keypair) { OpenSSL::PKey.generate_key('ml-dsa-44') }

      it 'does not verify document' do
        expect(described_class.verify_mldsa44_jcs_2024(secured_json, keypair)).to be false
      end
    end
  end
end
