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
        asn1 = OpenSSL::ASN1::Sequence(
          [
            OpenSSL::ASN1::Sequence([OpenSSL::ASN1::ObjectId('ED25519')]),
            OpenSSL::ASN1::BitString(Multibase.decode_multicodec('z6MkrJVnaZkeFzdQyMZu1cgjg7k1pZZ6pvBQ7XJPt4swbTQ2')[1]),
          ]
        )
        keypair = OpenSSL::PKey.read(asn1.to_der)

        Fabricate(:keypair, account: actor, uri: 'https://server.example/users/alice#ed25519-key', type: :ed25519, public_key: keypair.public_to_pem)
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
        asn1 = OpenSSL::ASN1::Sequence(
          [
            OpenSSL::ASN1::Sequence([OpenSSL::ASN1::ObjectId('ED25519')]),
            OpenSSL::ASN1::BitString(Multibase.decode_multicodec('z6MkrJVnaZkeFzdQyMZu1cgjg7k1pZZ6pvBQ7XJPt4swbTQ2')[1]),
          ]
        )
        keypair = OpenSSL::PKey.read(asn1.to_der)

        Fabricate(:keypair, account: actor, uri: 'https://server.example/users/alice#ed25519-key', type: :ed25519, public_key: keypair.public_to_pem)
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
        asn1 = OpenSSL::ASN1::Sequence(
          [
            OpenSSL::ASN1::Sequence([OpenSSL::ASN1::ObjectId('ED25519')]),
            OpenSSL::ASN1::BitString(Multibase.decode_multicodec('z6MkrJVnaZkeFzdQyMZu1cgjg7k1pZZ6pvBQ7XJPt4swbTQ2')[1]),
          ]
        )
        keypair = OpenSSL::PKey.read(asn1.to_der)

        Fabricate(:keypair, account: actor, uri: 'https://server.example/users/alice#ed25519-key', type: :ed25519, public_key: keypair.public_to_pem)
      end

      it 'returns nil' do
        expect(described_class.new(json).verify_actor!).to be_nil
      end
    end
  end

  describe 'verify_eddsa_jcs_2022' do
    # https://www.w3.org/TR/vc-di-eddsa/#representation-eddsa-jcs-2022

    let(:keypair) do
      asn1 = OpenSSL::ASN1::Sequence(
        [
          OpenSSL::ASN1::Sequence([OpenSSL::ASN1::ObjectId('ED25519')]),
          OpenSSL::ASN1::BitString(Multibase.decode_multicodec('z6MkrJVnaZkeFzdQyMZu1cgjg7k1pZZ6pvBQ7XJPt4swbTQ2')[1]),
        ]
      )

      OpenSSL::PKey.read(asn1.to_der)
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
end
