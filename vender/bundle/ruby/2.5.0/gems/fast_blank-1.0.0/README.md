### String blank? Ruby Extension

[![Gem Version](https://badge.fury.io/rb/fast_blank.png)](http://badge.fury.io/rb/fast_blank) [![Build Status](https://travis-ci.org/SamSaffron/fast_blank.png?branch=master)](https://travis-ci.org/SamSaffron/fast_blank)

`fast_blank` is a simple extension which provides a fast implementation of active support's string#blank? function

### How do you use it?

    require 'fast_blank'

### How fast is "Fast"?


About 5-9x faster than current active support, on my machine (your mileage my vary):

    $ ./benchmark

```
                          user     system      total        real
                                            user     system      total        real
Fast Blank 0    :                       0.070000   0.000000   0.070000 (  0.075247)
Fast Blank (Active Support)  0    :     0.080000   0.000000   0.080000 (  0.075029)
Slow Blank 0    :                       0.500000   0.000000   0.500000 (  0.503026)
Fast Blank 6    :                       0.200000   0.000000   0.200000 (  0.191480)
Fast Blank (Active Support)  6    :     0.180000   0.000000   0.180000 (  0.179891)
Slow Blank 6    :                       0.660000   0.000000   0.660000 (  0.658604)
Fast Blank 14    :                      0.080000   0.010000   0.090000 (  0.086371)
Fast Blank (Active Support)  14    :    0.130000   0.000000   0.130000 (  0.129258)
Slow Blank 14    :                      0.890000   0.000000   0.890000 (  0.886140)
Fast Blank 24    :                      0.150000   0.000000   0.150000 (  0.158151)
Fast Blank (Active Support)  24    :    0.140000   0.000000   0.140000 (  0.149284)
Slow Blank 24    :                      0.900000   0.000000   0.900000 (  0.899663)
Fast Blank 136    :                     0.130000   0.000000   0.130000 (  0.125831)
Fast Blank (Active Support)  136    :   0.150000   0.000000   0.150000 (  0.148948)
Slow Blank 136    :                     0.900000   0.000000   0.900000 (  0.899885)


```


Additionally, this gem allocates no strings during the test, making it less of a GC burden.


###Compatibility note:

fast_blank is supported under MRI Ruby 1.9.3, 2.0 and 2.1, earlier versions of MRI are untested.

fast_blank implements string.blank? as MRI would have it implemented, meaning it has 100% parity with `String#strip.length == 0`.


Active Supports version looks also at unicode spaces  
for example: `"\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000".blank?` is true in Active Support even though fast_blank would treat it as not blank.

fast_blank also provides blank_as? which is a 100% compatible blank? replacement.

Author: Sam Saffron sam.saffron@gmail.com  
http://github.com/SamSaffron/fast_blank    
License: MIT  

### Change log:

0.0.2:
  - Removed rake dependency (tmm1)
  - Unrolled internal loop to improve perf (tmm1)

(gem template based on https://github.com/CodeMonkeySteve/fast_xor )
