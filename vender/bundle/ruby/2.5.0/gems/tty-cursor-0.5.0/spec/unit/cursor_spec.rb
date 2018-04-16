# encoding: utf-8

RSpec.describe TTY::Cursor do
  subject(:cursor) { described_class }

  it "shows cursor" do
    expect(cursor.show).to eq("\e[?25h")
  end

  it "hides cursor" do
    expect(cursor.hide).to eq("\e[?25l")
  end

  it "saves cursor position" do
    allow(Gem).to receive(:win_platform?).and_return(false)

    expect(cursor.save).to eq("\e7")
  end

  it "saves cursor position on Windows" do
    allow(Gem).to receive(:win_platform?).and_return(true)

    expect(cursor.save).to eq("\e[s")
  end

  it "restores cursor position" do
    allow(Gem).to receive(:win_platform?).and_return(false)

    expect(cursor.restore).to eq("\e8")
  end

  it "restores cursor position on Windows" do
    allow(Gem).to receive(:win_platform?).and_return(true)

    expect(cursor.restore).to eq("\e[u")
  end

  it "gets current cursor position" do
    expect(cursor.current).to eq("\e[6n")
  end

  it "moves cursor up default by 1 line" do
    expect(cursor.up).to eq("\e[1A")
  end

  it "moves cursor up by 5 lines" do
    expect(cursor.up(5)).to eq("\e[5A")
  end

  it "moves cursor down default by 1 line" do
    expect(cursor.down).to eq("\e[1B")
  end

  it "moves cursor down by 5 lines" do
    expect(cursor.down(5)).to eq("\e[5B")
  end

  it "moves cursorleft by 1 line default" do
    expect(cursor.backward).to eq("\e[1D")
  end

  it "moves cursor left by 5" do
    expect(cursor.backward(5)).to eq("\e[5D")
  end

  it "moves cursor right by 1 line default" do
    expect(cursor.forward).to eq("\e[1C")
  end

  it "moves cursor right by 5 lines" do
    expect(cursor.forward(5)).to eq("\e[5C")
  end

  it "moves cursor horizontal to start" do
    expect(cursor.column).to eq("\e[1G")
  end

  it "moves cursor horizontally to 66th position" do
    expect(cursor.column(66)).to eq("\e[66G")
  end

  it "moves cursor vertically to start" do
    expect(cursor.row).to eq("\e[1d")
  end

  it "moves cursor vertically to 50th row" do
    expect(cursor.row(50)).to eq("\e[50d")
  end

  it "moves cursor to next line" do
    expect(cursor.next_line).to eq("\e[E\e[1G")
  end

  it "moves cursor to previous line" do
    expect(cursor.prev_line).to eq("\e[A\e[1G")
  end

  it "hides cursor for the duration of block call" do
    stream = StringIO.new
    cursor.invisible(stream) { }
    expect(stream.string).to eq("\e[?25l\e[?25h")
  end
end
