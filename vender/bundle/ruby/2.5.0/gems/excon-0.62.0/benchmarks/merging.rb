require 'rubygems'
require 'tach'

Tach.meter(10_000) do

  tach('merge') do
    default = { :a => 1, :b => 2 }
    override = { :b => 3, :c => 4 }
    override = default.merge(override)
  end

  tach('loop') do
    default = { :a => 1, :b => 2 }
    override = { :b => 3, :c => 4 }
    for key, value in default
      override[key] ||= default[key]
    end
    override
  end

end
