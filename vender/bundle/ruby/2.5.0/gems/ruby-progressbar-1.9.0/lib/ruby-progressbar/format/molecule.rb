class   ProgressBar
module  Format
class   Molecule
  MOLECULES = {
    :t => [:title_comp,   :title],
    :T => [:title_comp,   :title],
    :c => [:progressable, :progress],
    :C => [:progressable, :total],
    :u => [:progressable, :total_with_unknown_indicator],
    :p => [:percentage,   :percentage],
    :P => [:percentage,   :percentage_with_precision],
    :j => [:percentage,   :justified_percentage],
    :J => [:percentage,   :justified_percentage_with_precision],
    :a => [:time,         :elapsed_with_label],
    :e => [:time,         :estimated_with_unknown_oob],
    :E => [:time,         :estimated_with_friendly_oob],
    :f => [:time,         :estimated_with_no_oob],
    :B => [:bar,          :complete_bar],
    :b => [:bar,          :bar],
    :w => [:bar,          :bar_with_percentage],
    :i => [:bar,          :incomplete_space],
    :r => [:rate,         :rate_of_change],
    :R => [:rate,         :rate_of_change_with_precision]
  }.freeze

  BAR_MOLECULES = %w{w B b i}.freeze

  attr_accessor :key,
                :method_name

  def initialize(letter)
    self.key         = letter
    self.method_name = MOLECULES.fetch(key.to_sym)
  end

  def bar_molecule?
    BAR_MOLECULES.include? key
  end

  def non_bar_molecule?
    !bar_molecule?
  end

  def full_key
    "%#{key}"
  end

  def lookup_value(environment, length = 0)
    component = environment.__send__(method_name[0])

    if bar_molecule?
      component.__send__(method_name[1], length).to_s
    else
      component.__send__(method_name[1]).to_s
    end
  end
end
end
end
