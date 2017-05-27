require 'rails_helper'

RSpec.describe Mute, type: :model do
  it_behaves_like 'RecentOrderable', :mute
end
