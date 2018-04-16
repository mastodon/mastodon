class   ProgressBar
module  Format
class   Formatter
  def self.process(format_string, max_length, bar)
    processed_string = format_string.dup

    format_string.non_bar_molecules.each do |molecule|
      processed_string.gsub!(molecule.full_key, molecule.lookup_value(bar, nil))
    end

    processed_string.gsub!(/%%/, '%')

    bar_length         = max_length -
                         processed_string.displayable_length +
                         format_string.bar_molecule_placeholder_length
    bar_length         = (bar_length < 0) ? 0 : bar_length

    format_string.bar_molecules.each do |molecule|
      processed_string.gsub!(molecule.full_key,
                             molecule.lookup_value(bar, bar_length))
    end

    processed_string
  end
end
end
end
