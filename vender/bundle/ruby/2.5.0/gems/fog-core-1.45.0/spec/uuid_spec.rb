require "spec_helper"

describe "Fog::UUID" do
  it "#supported?" do
    Fog::UUID.supported? == SecureRandom.respond_to?(:uuid)
  end

  it "generates a valid UUID" do
    Fog::UUID.uuid =~ /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
  end
end
