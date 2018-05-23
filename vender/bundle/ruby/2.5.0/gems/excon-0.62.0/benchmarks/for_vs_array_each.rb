require 'rubygems'
require 'tach'

data = ["some", "var", "goes", "in", :here, 0]
Tach.meter(1_000_000) do
  tach('for') do
    for element in data
      element == nil
    end
  end
  tach('each') do
    data.each do |element|
      element == nil
    end
  end
end

# ruby 1.8.7 (2009-06-12 patchlevel 174) [universal-darwin10.0]
# 
# +------+----------+
# | tach | total    |
# +------+----------+
# | for  | 2.958672 |
# +------+----------+
# | each | 2.983550 |
# +------+----------+
# 
