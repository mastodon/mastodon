class   ProgressBar
module  Format
class   String < ::String
  MOLECULE_PATTERN = /%[a-zA-Z]/
  ANSI_SGR_PATTERN = /\e\[[\d;]+m/

  def displayable_length
    gsub(ANSI_SGR_PATTERN, '').length
  end

  def bar_molecule_placeholder_length
    @bar_molecule_placeholder_length ||= bar_molecules.size * 2
  end

  def non_bar_molecules
    @non_bar_molecules ||= molecules.select(&:non_bar_molecule?)
  end

  def bar_molecules
    @bar_molecules ||= molecules.select(&:bar_molecule?)
  end

  def molecules
    @molecules ||= begin
                      molecules = []

                      scan(MOLECULE_PATTERN) do |match|
                        molecules << Molecule.new(match[1, 1])
                      end

                      molecules
                    end
  end
end
end
end
