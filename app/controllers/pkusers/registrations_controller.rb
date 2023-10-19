# frozen_string_literal: true

class Pkusers::RegistrationsController < Devise::RegistrationsController
  include RelyingParty

  include Devise::Passkeys::Controllers::RegistrationsControllerConcern



end
