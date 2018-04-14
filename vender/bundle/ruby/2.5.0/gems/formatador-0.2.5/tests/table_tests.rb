Shindo.tests("Formatador: tables") do

output = <<-OUTPUT
    +---+
    | [bold]a[/] |
    +---+
    | 1 |
    +---+
    | 2 |
    +---+
OUTPUT
output = Formatador.parse(output)

  tests("#display_table([{:a => 1}, {:a => 2}])").returns(output) do
    capture_stdout do
      Formatador.display_table([{:a => 1}, {:a => 2}])
    end
  end

output = <<-OUTPUT
    +--------+
    | [bold]header[/] |
    +--------+
    +--------+
OUTPUT
output = Formatador.parse(output)

  tests("#display_table([], [:header])").returns(output) do
    capture_stdout do
      Formatador.display_table([], [:header])
    end
  end

output = <<-OUTPUT
    +--------+
    | [bold]header[/] |
    +--------+
    |        |
    +--------+
OUTPUT
output = Formatador.parse(output)

  tests("#display_table([{:a => 1}], [:header])").returns(output) do
    capture_stdout do
      Formatador.display_table([{:a => 1}], [:header])
    end
  end



output = <<-OUTPUT
    +---+------------+
    | [bold]a[/] | [bold]nested.key[/] |
    +---+------------+
    | 1 | value      |
    +---+------------+
OUTPUT
output = Formatador.parse(output)

  tests("#display_table([{:a => 1, :nested => {:key => 'value'}}], [:header, :'nested.key'])").returns(output) do
    capture_stdout do
      Formatador.display_table([{:a => 1, :nested => {:key => 'value'}}], [:a, :'nested.key'])
    end
  end

output = <<-OUTPUT
    +---+-----------------+
    | [bold]a[/] | [bold]nested[/]          |
    +---+-----------------+
    | 1 | {:key=>"value"} |
    +---+-----------------+
OUTPUT
output = Formatador.parse(output)

  tests("#display_table([{:a => 1, :nested => {:key => 'value'}}])").returns(output) do
    capture_stdout do
      Formatador.display_table([{:a => 1, :nested => {:key => 'value'}}])
    end
  end

output = <<-OUTPUT
    +---+--------------+
    | [bold]a[/] | [bold]just.pointed[/] |
    +---+--------------+
    | 1 | value        |
    +---+--------------+
OUTPUT
output = Formatador.parse(output)

  tests("#display_table([{:a => 1, 'just.pointed' => :value}])").returns(output) do
    capture_stdout do
      Formatador.display_table([{:a => 1, 'just.pointed' => :value}])
    end
  end

end