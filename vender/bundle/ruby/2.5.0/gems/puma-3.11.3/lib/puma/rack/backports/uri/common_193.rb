# :stopdoc:

require 'uri/common'

# Issue:
# http://bugs.ruby-lang.org/issues/5925
#
# Relevant commit:
# https://github.com/ruby/ruby/commit/edb7cdf1eabaff78dfa5ffedfbc2e91b29fa9ca1


module URI
  begin
    256.times do |i|
      TBLENCWWWCOMP_[i.chr] = '%%%02X' % i
    end
    TBLENCWWWCOMP_[' '] = '+'
    TBLENCWWWCOMP_.freeze

    256.times do |i|
      h, l = i>>4, i&15
      TBLDECWWWCOMP_['%%%X%X' % [h, l]] = i.chr
      TBLDECWWWCOMP_['%%%x%X' % [h, l]] = i.chr
      TBLDECWWWCOMP_['%%%X%x' % [h, l]] = i.chr
      TBLDECWWWCOMP_['%%%x%x' % [h, l]] = i.chr
    end
    TBLDECWWWCOMP_['+'] = ' '
    TBLDECWWWCOMP_.freeze
  rescue Exception
  end
end

# :startdoc:
