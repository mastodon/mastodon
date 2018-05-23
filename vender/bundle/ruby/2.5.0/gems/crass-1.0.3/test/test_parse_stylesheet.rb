# encoding: utf-8

require_relative 'support/common'
require_relative 'shared/parse_rules'

describe 'Crass::Parser' do
  make_my_diffs_pretty!
  parallelize_me!

  describe '#parse_stylesheet' do
    def parse(*args)
      CP.parse_stylesheet(*args)
    end

    behaves_like 'parsing a list of rules'
  end
end
