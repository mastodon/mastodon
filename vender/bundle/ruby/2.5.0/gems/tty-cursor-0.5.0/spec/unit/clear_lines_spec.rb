# encoding: utf-8

RSpec.describe TTY::Cursor, '#clear_lines' do
  subject(:cursor) { described_class }

  it "clears character" do
    expect(cursor.clear_char).to eq("\e[X")
  end

  it "clears few characters" do
    expect(cursor.clear_char(5)).to eq("\e[5X")
  end

  it "clears line" do
    expect(cursor.clear_line).to eq("\e[2K\e[1G")
  end

  it "clears the line before the cursor" do
    expect(cursor.clear_line_before).to eq("\e[0K")
  end

  it "clears the line after the cursor" do
    expect(cursor.clear_line_after).to eq("\e[1K")
  end

  it "clears 5 lines up" do
    expect(cursor.clear_lines(5)).to eq([
      "\e[2K\e[1G\e[1A",
      "\e[2K\e[1G\e[1A",
      "\e[2K\e[1G\e[1A",
      "\e[2K\e[1G\e[1A",
      "\e[2K\e[1G"
    ].join)
  end

  it "clears 5 lines down" do
    expect(cursor.clear_lines(5, :down)).to eq([
      "\e[2K\e[1G\e[1B",
      "\e[2K\e[1G\e[1B",
      "\e[2K\e[1G\e[1B",
      "\e[2K\e[1G\e[1B",
      "\e[2K\e[1G"
    ].join)
  end

  it "clears screen down" do
    expect(cursor.clear_screen_down).to eq("\e[J")
  end

  it "clears screen up" do
    expect(cursor.clear_screen_up).to eq("\e[1J")
  end

  it "clears entire screen" do
    expect(cursor.clear_screen).to eq("\e[2J")
  end
end
