

0.upto(255) { |i|
	printf "\n" if i%16 == 0
	printf "  "  if i%8 == 0
	s = ("" << i)
	if s =~ /[A-Z0-9\-_\/ ]/
		print "0x#{i.to_s(16)}," 	
	elsif s =~ /[a-z]/
		print "0x#{s.upcase[0].to_s(16)},"
	else
		print "0x00,"
	end

}
