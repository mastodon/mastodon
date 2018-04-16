require 'spec_helper_integration'

module Doorkeeper::OAuth
  describe BaseResponse do
    subject do
      BaseResponse.new
    end

    describe "#body" do
      it "returns an empty Hash" do
        expect(subject.body).to eq({})
      end
    end

    describe "#description" do
      it "returns an empty String" do
        expect(subject.description).to eq("")
      end
    end

    describe "#headers" do
      it "returns an empty Hash" do
        expect(subject.headers).to eq({})
      end
    end

    describe "#redirectable?" do
      it "returns false" do
        expect(subject.redirectable?).to eq(false)
      end
    end

    describe "#redirect_uri" do
      it "returns an empty String" do
        expect(subject.redirect_uri).to eq("")
      end
    end

    describe "#status" do
      it "returns :ok" do
        expect(subject.status).to eq(:ok)
      end
    end
  end
end
