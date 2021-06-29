require "rails_helper"

describe "The catch all route" do
  describe "with a simple value" do
    it "returns a 404 page as html" do
      get "/test"

      expect(response.status).to eq 404
      expect(response.media_type).to eq "text/html"
    end
  end

  describe "with an implied format" do
    it "returns a 404 page as html" do
      get "/test.test"

      expect(response.status).to eq 404
      expect(response.media_type).to eq "text/html"
    end
  end
end
