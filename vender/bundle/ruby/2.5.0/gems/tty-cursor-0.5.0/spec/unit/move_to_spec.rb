# encoding: utf-8

RSpec.describe TTY::Cursor, '#move_to' do
  subject(:cursor) { described_class }

  it "moves to home" do
    expect(cursor.move_to). to eq("\e[H")
  end

  it "moves to row and column" do
    expect(cursor.move_to(2, 3)).to eq("\e[4;3H")
  end
end
