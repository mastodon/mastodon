

def printbytes str
str.each_byte { |b|
	print "0x#{b.to_s(16)}, "
}
end

if $0 == __FILE__
	printf "static final byte [] #{ARGV[0]} = {\n"
	printbytes ARGV[0]
	printf "\n};\n"
end
