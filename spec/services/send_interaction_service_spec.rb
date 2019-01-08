require 'rails_helper'

RSpec.describe SendInteractionService, type: :service do
  subject { SendInteractionService.new }

  it 'sends an XML envelope to the Salmon end point of remote user'
end
