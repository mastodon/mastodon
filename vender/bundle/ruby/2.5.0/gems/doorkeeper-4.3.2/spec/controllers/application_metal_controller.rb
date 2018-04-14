require "spec_helper_integration"

describe Doorkeeper::ApplicationMetalController do
  it "lazy run hooks" do
    i = 0
    ActiveSupport.on_load(:doorkeeper_metal_controller) { i += 1 }

    expect(i).to eq 1
  end
end
