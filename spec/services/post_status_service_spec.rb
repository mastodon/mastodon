require 'rails_helper'

RSpec.describe PostStatusService do
  subject { PostStatusService.new }

  it 'creates a new status'
  it 'creates a new response status'
  it 'processes mentions'
  it 'pings PuSH hubs'
end
