require "rails_helper"

describe "site_title" do
  it "Uses the Setting.site_title value when it exists" do
    Setting.site_title = "New site title"

    expect(helper.site_title).to eq "New site title"
  end

  it "returns empty string when Setting.site_title is nil" do
    Setting.site_title = nil

    expect(helper.site_title).to eq ""
  end
end
