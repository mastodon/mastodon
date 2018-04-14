
"A".upto("Z") {|c|
	puts "public static final byte #{c} = 0x#{c[0].to_s(16)};"
}


