require 'fast_blank'

class ::String
  def blank2?
    /\A[[:space:]]*\z/ === self
  end
end

describe String do
  it "works" do
    expect("".blank?).to eq(true)
    expect(" ".blank?).to eq(true)
    expect("\r\n".blank?).to eq(true)
    "\r\n\v\f\r\s\u0085".blank? == true
  end

  it "provides a parity with active support function" do
    (16*16*16*16).times do |i|
      c = i.chr('UTF-8') rescue nil
      unless c.nil?
        expect("#{i.to_s(16)} #{c.blank_as?}").to eq("#{i.to_s(16)} #{c.blank2?}")
      end
    end


    (256).times do |i|
      c = i.chr('ASCII') rescue nil
      unless c.nil?
        expect("#{i.to_s(16)} #{c.blank_as?}").to eq("#{i.to_s(16)} #{c.blank2?}")
      end
    end
  end

  it "has parity with strip.length" do
    (256).times do |i|
      c = i.chr('ASCII') rescue nil
      unless c.nil?
        expect("#{i.to_s(16)} #{c.strip.length == 0}").to eq("#{i.to_s(16)} #{c.blank?}")
      end
    end
  end

  it "treats \u0000 correctly" do
    # odd I know
    expect("\u0000".strip.length).to eq(0)
    expect("\u0000".blank_as?).to be_falsey
    expect("\u0000".blank?).to be_truthy
  end

end
