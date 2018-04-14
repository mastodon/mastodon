require 'net/ldap/auth_adapter'

module Net
  class LDAP
    class AuthAdapter
      class Sasl < Net::LDAP::AuthAdapter
        MAX_SASL_CHALLENGES = 10

        #--
        # Required parameters: :mechanism, :initial_credential and
        # :challenge_response
        #
        # Mechanism is a string value that will be passed in the SASL-packet's
        # "mechanism" field.
        #
        # Initial credential is most likely a string. It's passed in the initial
        # BindRequest that goes to the server. In some protocols, it may be empty.
        #
        # Challenge-response is a Ruby proc that takes a single parameter and
        # returns an object that will typically be a string. The
        # challenge-response block is called when the server returns a
        # BindResponse with a result code of 14 (saslBindInProgress). The
        # challenge-response block receives a parameter containing the data
        # returned by the server in the saslServerCreds field of the LDAP
        # BindResponse packet. The challenge-response block may be called multiple
        # times during the course of a SASL authentication, and each time it must
        # return a value that will be passed back to the server as the credential
        # data in the next BindRequest packet.
        #++
        def bind(auth)
          mech, cred, chall = auth[:mechanism], auth[:initial_credential],
            auth[:challenge_response]
          raise Net::LDAP::BindingInformationInvalidError, "Invalid binding information" unless (mech && cred && chall)

          message_id = @connection.next_msgid

          n = 0
          loop do
            sasl = [mech.to_ber, cred.to_ber].to_ber_contextspecific(3)
            request = [
              Net::LDAP::Connection::LdapVersion.to_ber, "".to_ber, sasl
            ].to_ber_appsequence(Net::LDAP::PDU::BindRequest)

            @connection.send(:write, request, nil, message_id)
            pdu = @connection.queued_read(message_id)

            if !pdu || pdu.app_tag != Net::LDAP::PDU::BindResult
              raise Net::LDAP::NoBindResultError, "no bind result"
            end

            return pdu unless pdu.result_code == Net::LDAP::ResultCodeSaslBindInProgress
            raise Net::LDAP::SASLChallengeOverflowError, "sasl-challenge overflow" if ((n += 1) > MAX_SASL_CHALLENGES)

            cred = chall.call(pdu.result_server_sasl_creds)
          end

          raise Net::LDAP::SASLChallengeOverflowError, "why are we here?"
        end
      end
    end
  end
end
