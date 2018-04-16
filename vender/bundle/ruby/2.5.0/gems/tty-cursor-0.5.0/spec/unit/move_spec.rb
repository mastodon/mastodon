# encoding: utf-8

RSpec.describe TTY::Cursor, '#move' do
  subject(:cursor) { described_class }

  it "doesn't move for point (0, 0)" do
    expect(cursor.move(0, 0)).to eq('')
  end

  it "moves only to the right" do
    expect(cursor.move(2, 0)).to eq("\e[2C")
  end

  it "moves right and up" do
    expect(cursor.move(2, 3)).to eq("\e[2C\e[3A")
  end

  it "moves right and down" do
    expect(cursor.move(2, -3)).to eq("\e[2C\e[3B")
  end

  it "moves left and up" do
    expect(cursor.move(-2, 3)).to eq("\e[2D\e[3A")
  end

  it "moves left and down" do
    expect(cursor.move(-2, -3)).to eq("\e[2D\e[3B")
  end
end
