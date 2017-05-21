require 'tmpdir'
require 'pathname'

def lightness(v)
  sprintf("%03d", v + 100)
end

def alpha(t)
  sprintf("%03d", t.to_f * 100)
end

def variable_name(colorspec)
  case colorspec
  when /^lighten\(\$(.+), (\d+)\%\)$/
    "$#{$1}--l#{lightness($2.to_i)}-a100"
  when /^darken\(\$(.+), (\d+)\%\)$/
    "$#{$1}--l#{lightness(- $2.to_i)}-a100"
  when /^rgba\(\$(.+), ([\d\.]+)\)$/
    "$#{$1}--l100-a#{alpha($2)}"
  when /^rgba\(lighten\(\$(.+), (\d+)\%\), ([\d\.]+)\)$/
    "$#{$1}--l#{lightness($2.to_i)}-a#{alpha($3)}"
  when /^rgba\(darken\(\$(.+), (\d+)\%\), ([\d\.]+)\)$/
    "$#{$1}--l#{lightness(- $2.to_i)}-a#{alpha($3)}"
  else
    raise "no variable name: #{colorspec}"
  end
end


targets = Pathname.glob('app/javascript/styles/*.scss').reject{|f| f.basename.to_s == "variables.scss"}
target_contents = targets.map{|f| f.read}.join
color_specs = target_contents.scan(/(?<paren>(?:darken|lighten|rgba)\((?:[^()]|\g<paren>)*\))/).flatten.uniq.sort_by{|c, v| - c.scan(/\(/).size}
color_variations = color_specs.map{|v| [v, variable_name(v)]}

targets.each do |target|
  converted = color_variations.inject(target.read){|l, (colorspec, variable)| l.gsub(colorspec, variable)}
  target.write(converted)
end

variables = Pathname.new('app/javascript/styles/variables.scss')
text = variables.read
text << "\n"
text << "// Color variations\n"
color_variations.sort_by{|c, v| v}.each do |colorspec, variable|
  text << "#{variable}: #{colorspec} !default;\n"
end
variables.write(text)

