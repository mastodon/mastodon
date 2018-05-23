# coding: utf-8

RSpec.describe Pastel::AliasImporter, '#import' do
  let(:color) { spy(:color, alias_color: true) }
  let(:output) { StringIO.new }

  it "imports aliases from environment" do
    color_aliases = "funky=red.bold,base=bright_yellow"
    env = {'PASTEL_COLORS_ALIASES' => color_aliases}
    importer = described_class.new(color, env)

    importer.import

    expect(color).to have_received(:alias_color).with(:funky, :red, :bold)
    expect(color).to have_received(:alias_color).with(:base, :bright_yellow)
  end

  it "fails to import incorrectly formatted colors" do
    color_aliases = "funky red,base=bright_yellow"
    env = {'PASTEL_COLORS_ALIASES' => color_aliases}
    importer = described_class.new(color, env, output)
    output.rewind

    importer.import

    expect(output.string).to eq("Bad color mapping `funky red`\n")
    expect(color).to have_received(:alias_color).with(:base, :bright_yellow)
  end
end
