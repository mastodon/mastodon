Shindo.tests("Formatador: basics") do

  tests("#display_line(Formatador)").returns("    Formatador\n") do
    capture_stdout do
      Formatador.display_line('Formatador')
    end
  end

output = <<-OUTPUT
    one
    two
OUTPUT
output = Formatador.parse(output)

  tests("#display_lines(['one', 'two']").returns(output) do
    capture_stdout do
      Formatador.display_lines(['one', 'two'])
    end
  end

  tests("#indent { display_line('Formatador') }").returns("      Formatador\n") do
    capture_stdout do
      Formatador.indent do
        Formatador.display_line('Formatador')
      end
    end
  end

end
