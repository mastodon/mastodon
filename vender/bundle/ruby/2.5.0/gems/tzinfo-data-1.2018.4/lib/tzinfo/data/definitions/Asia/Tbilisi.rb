# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Tbilisi
          include TimezoneDefinition
          
          timezone 'Asia/Tbilisi' do |tz|
            tz.offset :o0, 10751, 0, :LMT
            tz.offset :o1, 10751, 0, :TBMT
            tz.offset :o2, 10800, 0, :'+03'
            tz.offset :o3, 14400, 0, :'+04'
            tz.offset :o4, 14400, 3600, :'+05'
            tz.offset :o5, 10800, 3600, :'+04'
            
            tz.transition 1879, 12, :o1, -2840151551, 208026608449, 86400
            tz.transition 1924, 5, :o2, -1441162751, 209425597249, 86400
            tz.transition 1957, 2, :o3, -405140400, 19487187, 8
            tz.transition 1981, 3, :o4, 354916800
            tz.transition 1981, 9, :o3, 370724400
            tz.transition 1982, 3, :o4, 386452800
            tz.transition 1982, 9, :o3, 402260400
            tz.transition 1983, 3, :o4, 417988800
            tz.transition 1983, 9, :o3, 433796400
            tz.transition 1984, 3, :o4, 449611200
            tz.transition 1984, 9, :o3, 465343200
            tz.transition 1985, 3, :o4, 481068000
            tz.transition 1985, 9, :o3, 496792800
            tz.transition 1986, 3, :o4, 512517600
            tz.transition 1986, 9, :o3, 528242400
            tz.transition 1987, 3, :o4, 543967200
            tz.transition 1987, 9, :o3, 559692000
            tz.transition 1988, 3, :o4, 575416800
            tz.transition 1988, 9, :o3, 591141600
            tz.transition 1989, 3, :o4, 606866400
            tz.transition 1989, 9, :o3, 622591200
            tz.transition 1990, 3, :o4, 638316000
            tz.transition 1990, 9, :o3, 654645600
            tz.transition 1991, 3, :o5, 670370400
            tz.transition 1991, 9, :o2, 686098800
            tz.transition 1992, 3, :o5, 701816400
            tz.transition 1992, 9, :o2, 717537600
            tz.transition 1993, 3, :o5, 733266000
            tz.transition 1993, 9, :o2, 748987200
            tz.transition 1994, 3, :o5, 764715600
            tz.transition 1994, 9, :o3, 780436800
            tz.transition 1995, 3, :o4, 796161600
            tz.transition 1995, 9, :o3, 811882800
            tz.transition 1996, 3, :o4, 828216000
            tz.transition 1997, 3, :o4, 859662000
            tz.transition 1997, 10, :o3, 877806000
            tz.transition 1998, 3, :o4, 891115200
            tz.transition 1998, 10, :o3, 909255600
            tz.transition 1999, 3, :o4, 922564800
            tz.transition 1999, 10, :o3, 941310000
            tz.transition 2000, 3, :o4, 954014400
            tz.transition 2000, 10, :o3, 972759600
            tz.transition 2001, 3, :o4, 985464000
            tz.transition 2001, 10, :o3, 1004209200
            tz.transition 2002, 3, :o4, 1017518400
            tz.transition 2002, 10, :o3, 1035658800
            tz.transition 2003, 3, :o4, 1048968000
            tz.transition 2003, 10, :o3, 1067108400
            tz.transition 2004, 3, :o4, 1080417600
            tz.transition 2004, 6, :o5, 1088276400
            tz.transition 2004, 10, :o2, 1099177200
            tz.transition 2005, 3, :o3, 1111878000
          end
        end
      end
    end
  end
end
