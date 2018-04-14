RSpec.describe TTY::Screen, '#height,#width' do
  it "calcualtes screen width" do
    allow(TTY::Screen).to receive(:size).and_return([51, 280])
    expect(TTY::Screen.width).to eq(280)
  end

  it "aliases width to columns" do
    allow(TTY::Screen).to receive(:size).and_return([51, 280])
    expect(TTY::Screen.columns).to eq(280)
  end

  it "aliases width to cols" do
    allow(TTY::Screen).to receive(:size).and_return([51, 280])
    expect(TTY::Screen.cols).to eq(280)
  end

  it "calcualtes screen height" do
    allow(TTY::Screen).to receive(:size).and_return([51, 280])
    expect(TTY::Screen.height).to eq(51)
  end

  it "aliases width to rows" do
    allow(TTY::Screen).to receive(:size).and_return([51, 280])
    expect(TTY::Screen.rows).to eq(51)
  end

  it "aliases width to lines" do
    allow(TTY::Screen).to receive(:size).and_return([51, 280])
    expect(TTY::Screen.lines).to eq(51)
  end
end
