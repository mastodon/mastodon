require 'rubygems'
require 'tach'

data = {"some" => "var", "goes" => "in", :here => 0}
Tach.meter(1_000_000) do
  tach('for') do
    for key, values in data
      key == values
    end
  end
  tach('each') do
    data.each do |key, values|
      key == values
    end
  end
end

# ruby 1.8.7 (2009-06-12 patchlevel 174) [universal-darwin10.0]
# 
# +------+----------+
# | tach | total    |
# +------+----------+
# | each | 2.748909 |
# +------+----------+
# | for  | 2.949512 |
# +------+----------+
#
