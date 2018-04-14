#ifndef UNF_UTIL_HH
#define UNF_UTIL_HH

namespace UNF {
  namespace Util {
    inline bool is_utf8_char_start_byte(char byte) {
      if(!(byte&0x80))    return true; // ascii
      else if (byte&0x40) return true; // start of a UTF-8 character byte sequence
      return false;
    }

    inline const char* nearest_utf8_char_start_point(const char* s) {
      for(; is_utf8_char_start_byte(*s)==false; s++);
      return s;
    }

    template <class CharStream>
    inline void eat_until_utf8_char_start_point(CharStream& in) {
      for(; is_utf8_char_start_byte(in.peek())==false; in.read());
    }
  }
}

#endif
