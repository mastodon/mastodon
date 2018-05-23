# encoding: utf-8

RSpec.describe TTY::Color, 'integratation' do
  it "accesses color mode" do
    mode_instance = spy(:mode)
    allow(TTY::Color::Mode).to receive(:new).and_return(mode_instance)

    described_class.mode

    expect(mode_instance).to have_received(:mode)
  end

  it "accesses color support" do
    support_instance = spy(:support)
    allow(TTY::Color::Support).to receive(:new).and_return(support_instance)

    described_class.supports?

    expect(support_instance).to have_received(:supports?)
  end
end
