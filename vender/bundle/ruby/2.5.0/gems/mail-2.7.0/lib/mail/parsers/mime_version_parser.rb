
# frozen_string_literal: true
require 'mail/utilities'
require 'mail/parser_tools'




module Mail::Parsers
  module MimeVersionParser
    extend Mail::ParserTools

    MimeVersionStruct = Struct.new(:major, :minor, :error)

    
class << self
	attr_accessor :_trans_keys
	private :_trans_keys, :_trans_keys=
end
self._trans_keys = [
	0, 0, 9, 57, 10, 10, 
	9, 32, 9, 57, 40, 
	57, 46, 46, 40, 57, 
	48, 57, 10, 10, 9, 32, 
	1, 244, 1, 244, 10, 
	10, 9, 32, 0, 244, 
	128, 191, 160, 191, 128, 191, 
	128, 159, 144, 191, 128, 
	191, 128, 143, 9, 57, 
	9, 40, 9, 40, 0, 0, 
	0
]

class << self
	attr_accessor :_key_spans
	private :_key_spans, :_key_spans=
end
self._key_spans = [
	0, 49, 1, 24, 49, 18, 1, 18, 
	10, 1, 24, 244, 244, 1, 24, 245, 
	64, 32, 64, 32, 48, 64, 16, 49, 
	32, 32, 0
]

class << self
	attr_accessor :_index_offsets
	private :_index_offsets, :_index_offsets=
end
self._index_offsets = [
	0, 0, 50, 52, 77, 127, 146, 148, 
	167, 178, 180, 205, 450, 695, 697, 722, 
	968, 1033, 1066, 1131, 1164, 1213, 1278, 1295, 
	1345, 1378, 1411
]

class << self
	attr_accessor :_indicies
	private :_indicies, :_indicies=
end
self._indicies = [
	0, 1, 1, 1, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 0, 
	1, 1, 1, 1, 1, 1, 1, 3, 
	1, 1, 1, 1, 1, 1, 1, 4, 
	4, 4, 4, 4, 4, 4, 4, 4, 
	4, 1, 5, 1, 0, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 0, 1, 6, 1, 1, 
	1, 7, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 6, 1, 1, 1, 
	1, 1, 1, 1, 8, 1, 1, 1, 
	1, 1, 1, 1, 9, 9, 9, 9, 
	9, 9, 9, 9, 9, 9, 1, 10, 
	1, 1, 1, 1, 1, 11, 1, 12, 
	12, 12, 12, 12, 12, 12, 12, 12, 
	12, 1, 13, 1, 14, 1, 1, 1, 
	1, 1, 1, 1, 15, 15, 15, 15, 
	15, 15, 15, 15, 15, 15, 1, 16, 
	16, 16, 16, 16, 16, 16, 16, 16, 
	16, 1, 17, 1, 18, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 18, 1, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 1, 19, 
	19, 20, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 21, 22, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	23, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 19, 19, 19, 19, 
	19, 19, 19, 19, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 24, 24, 
	24, 24, 24, 24, 24, 24, 24, 24, 
	24, 24, 24, 24, 24, 24, 24, 24, 
	24, 24, 24, 24, 24, 24, 24, 24, 
	24, 24, 24, 24, 25, 26, 26, 26, 
	26, 26, 26, 26, 26, 26, 26, 26, 
	26, 27, 26, 26, 28, 29, 29, 29, 
	30, 1, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 1, 31, 31, 32, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 33, 34, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 35, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 37, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 39, 38, 
	38, 40, 41, 41, 41, 42, 1, 43, 
	1, 31, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	31, 1, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 37, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 39, 
	38, 38, 40, 41, 41, 41, 42, 1, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	31, 31, 31, 31, 31, 31, 31, 31, 
	1, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 1, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 1, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 36, 36, 36, 36, 36, 
	36, 36, 36, 1, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 1, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 1, 38, 38, 
	38, 38, 38, 38, 38, 38, 38, 38, 
	38, 38, 38, 38, 38, 38, 1, 44, 
	1, 1, 1, 45, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 44, 1, 
	1, 1, 1, 1, 1, 1, 46, 1, 
	1, 1, 1, 1, 1, 1, 47, 47, 
	47, 47, 47, 47, 47, 47, 47, 47, 
	1, 18, 1, 1, 1, 48, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	18, 1, 1, 1, 1, 1, 1, 1, 
	49, 1, 50, 1, 1, 1, 51, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 50, 1, 1, 1, 1, 1, 1, 
	1, 52, 1, 1, 0
]

class << self
	attr_accessor :_trans_targs
	private :_trans_targs, :_trans_targs=
end
self._trans_targs = [
	1, 0, 2, 4, 5, 3, 1, 2, 
	4, 5, 6, 7, 5, 7, 8, 23, 
	23, 10, 24, 12, 13, 12, 26, 15, 
	16, 17, 18, 19, 20, 21, 22, 12, 
	13, 12, 26, 15, 16, 17, 18, 19, 
	20, 21, 22, 14, 24, 9, 25, 23, 
	9, 25, 24, 9, 25
]

class << self
	attr_accessor :_trans_actions
	private :_trans_actions, :_trans_actions=
end
self._trans_actions = [
	0, 0, 0, 1, 2, 0, 3, 3, 
	4, 5, 6, 7, 0, 3, 1, 8, 
	9, 0, 0, 10, 10, 11, 12, 10, 
	10, 10, 10, 10, 10, 10, 10, 0, 
	0, 1, 13, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 14, 14, 15, 0, 
	0, 1, 3, 3, 4
]

class << self
	attr_accessor :_eof_actions
	private :_eof_actions, :_eof_actions=
end
self._eof_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 14, 
	0, 3, 0
]

class << self
	attr_accessor :start
end
self.start = 1;
class << self
	attr_accessor :first_final
end
self.first_final = 23;
class << self
	attr_accessor :error
end
self.error = 0;

class << self
	attr_accessor :en_comment_tail
end
self.en_comment_tail = 11;
class << self
	attr_accessor :en_main
end
self.en_main = 1;



    def self.parse(data)
      data = data.dup.force_encoding(Encoding::ASCII_8BIT) if data.respond_to?(:force_encoding)

      return MimeVersionStruct.new('', nil) if Mail::Utilities.blank?(data)

      # Parser state
      mime_version = MimeVersionStruct.new
      major_digits_s = minor_digits_s = nil

      # 5.1 Variables Used by Ragel
      p = 0
      eof = pe = data.length
      stack = []

      
begin
	p ||= 0
	pe ||= data.length
	cs = start
	top = 0
end

      
begin
	testEof = false
	_slen, _trans, _keys, _inds, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_keys = cs << 1
	_inds = _index_offsets[cs]
	_slen = _key_spans[cs]
	_wide = data[p].ord
	_trans = if (   _slen > 0 && 
			_trans_keys[_keys] <= _wide && 
			_wide <= _trans_keys[_keys + 1] 
		    ) then
			_indicies[ _inds + _wide - _trans_keys[_keys] ] 
		 else 
			_indicies[ _inds + _slen ]
		 end
	cs = _trans_targs[_trans]
	if _trans_actions[_trans] != 0
	case _trans_actions[_trans]
	when 2 then
		begin
 major_digits_s = p 		end
	when 7 then
		begin
 mime_version.major = chars(data, major_digits_s, p-1) 		end
	when 8 then
		begin
 minor_digits_s = p 		end
	when 14 then
		begin
 mime_version.minor = chars(data, minor_digits_s, p-1) 		end
	when 10 then
		begin
		end
	when 3 then
		begin
		end
	when 1 then
		begin
 	begin
		stack[top] = cs
		top+= 1
		cs = 11
		_goto_level = _again
		next
	end
 		end
	when 13 then
		begin
 	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end
 		end
	when 6 then
		begin
 mime_version.major = chars(data, major_digits_s, p-1) 		end
		begin
 	begin
		stack[top] = cs
		top+= 1
		cs = 11
		_goto_level = _again
		next
	end
 		end
	when 15 then
		begin
 mime_version.minor = chars(data, minor_digits_s, p-1) 		end
		begin
 	begin
		stack[top] = cs
		top+= 1
		cs = 11
		_goto_level = _again
		next
	end
 		end
	when 11 then
		begin
		end
		begin
 	begin
		stack[top] = cs
		top+= 1
		cs = 11
		_goto_level = _again
		next
	end
 		end
	when 12 then
		begin
		end
		begin
 	begin
		top -= 1
		cs = stack[top]
		_goto_level = _again
		next
	end
 		end
	when 5 then
		begin
		end
		begin
 major_digits_s = p 		end
	when 9 then
		begin
		end
		begin
 minor_digits_s = p 		end
	when 4 then
		begin
		end
		begin
 	begin
		stack[top] = cs
		top+= 1
		cs = 11
		_goto_level = _again
		next
	end
 		end
	end
	end
	end
	if _goto_level <= _again
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	  case _eof_actions[cs]
	when 14 then
		begin
 mime_version.minor = chars(data, minor_digits_s, p-1) 		end
	when 3 then
		begin
		end
	  end
	end

	end
	if _goto_level <= _out
		break
	end
end
	end


      if p != eof || cs < 23
        raise Mail::Field::IncompleteParseError.new(Mail::MimeVersionElement, data, p)
      end

      mime_version
    end
  end
end
