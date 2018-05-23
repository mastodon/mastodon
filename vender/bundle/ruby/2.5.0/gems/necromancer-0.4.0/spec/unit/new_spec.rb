# encoding: utf-8

RSpec.describe Necromancer, '#new' do

  subject(:converter) { described_class.new }

  it "creates context" do
    expect(converter).to be_a(Necromancer::Context)
  end
end
