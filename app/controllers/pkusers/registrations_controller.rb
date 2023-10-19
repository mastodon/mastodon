# frozen_string_literal: true

class Pkusers::RegistrationsController < Devise::RegistrationsController
  include Devise::Passkeys::Controllers::RegistrationsControllerConcern
  include RelyingParty



end
