# frozen_string_literal: true

RSpec.describe HTTP::Options do
  subject { described_class.new(:response => :body) }

  it "has reader methods for attributes" do
    expect(subject.response).to eq(:body)
  end

  it "coerces to a Hash" do
    expect(subject.to_hash).to be_a(Hash)
  end
end
