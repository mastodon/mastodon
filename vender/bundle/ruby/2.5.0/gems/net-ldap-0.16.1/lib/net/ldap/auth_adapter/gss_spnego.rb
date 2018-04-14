require 'net/ldap/auth_adapter'
require 'net/ldap/auth_adapter/sasl'

module Net
  class LDAP
    module AuthAdapers
      #--
      # PROVISIONAL, only for testing SASL implementations. DON'T USE THIS YET.
      # Uses Kohei Kajimoto's Ruby/NTLM. We have to find a clean way to
      # integrate it without introducing an external dependency.
      #
      # This authentication method is accessed by calling #bind with a :method
      # parameter of :gss_spnego. It requires :username and :password
      # attributes, just like the :simple authentication method. It performs a
      # GSS-SPNEGO authentication with the server, which is presumed to be a
      # Microsoft Active Directory.
      #++
      class GSS_SPNEGO < Net::LDAP::AuthAdapter
        def bind(auth)
          require 'ntlm'

          user, psw = [auth[:username] || auth[:dn], auth[:password]]
          raise Net::LDAP::BindingInformationInvalidError, "Invalid binding information" unless (user && psw)

          nego = proc do |challenge|
            t2_msg = NTLM::Message.parse(challenge)
            t3_msg = t2_msg.response({ :user => user, :password => psw },
                                     { :ntlmv2 => true })
            t3_msg.serialize
          end

          Net::LDAP::AuthAdapter::Sasl.new(@connection).bind \
            :method             => :sasl,
            :mechanism          => "GSS-SPNEGO",
            :initial_credential => NTLM::Message::Type1.new.serialize,
            :challenge_response => nego
        end
      end
    end
  end
end
