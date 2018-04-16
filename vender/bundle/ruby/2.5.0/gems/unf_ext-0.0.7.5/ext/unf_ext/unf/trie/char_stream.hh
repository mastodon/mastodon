#ifndef UNF_TRIE_CHAR_STREAM_HH
#define UNF_TRIE_CHAR_STREAM_HH

#include <vector>
#include <string>
#include "../util.hh"

namespace UNF {
  namespace Trie {
    class CharStream {
    public:
      CharStream(const char* str) : cur_(str) {}
      unsigned char read() { return eos() ? '\0' : *cur_++; }
      unsigned char prev() const { return cur_[-1]; }
      unsigned char peek() const { return *cur_; } 
      const char*   cur() const { return cur_; }
      bool          eos() const { return *cur_ == '\0'; }
      void          setCur(const char* new_cur) { cur_ = new_cur; }

    private:
      const char* cur_;
    };

    class RangeCharStream {
    public:
      RangeCharStream(const char* beg, const char* end) : cur_(beg), end_(end) {}
      unsigned char read() { return eos() ? '\0' : *cur_++; }
      unsigned char prev() const { return cur_[-1]; }
      unsigned char peek() const { return *cur_; } 
      const char*   cur() const { return cur_; }
      const char*   end() const { return end_; }
      bool          eos() const { return cur_ == end_; }

    private:
      const char* cur_;
      const char* end_;
    };

    class CompoundCharStream {
    public:
      CompoundCharStream(const char* first, const char* second) 
	: beg1(first), beg2(second), cur1(beg1), cur2(beg2) {}

      unsigned char read() { return !eos1() ? read1() : read2(); }
      unsigned char peek() const { return !eos1() ? *cur1 : *cur2; }
      unsigned char prev() const { return !eos1() || beg2==cur2 ? cur1[-1] : cur2[-1]; }

      const char* cur() const { return !eos1() ? cur1 : cur2; }
      bool eos() const { return eos1() && eos2(); }
      bool within_first() const { return !eos1(); }

      unsigned offset() const { return cur1-beg1 + cur2-beg2; }
      void setCur(const char* p) { 
	if(beg1 <= p && p <= cur1) {
	  cur1=p;
	  cur2=beg2;
	} else {
	  cur2=p;
	}
      }

    protected:
      unsigned char read1() { return eos1() ? '\0' : *cur1++; }
      unsigned char read2() { return eos2() ? '\0' : *cur2++; }
      bool eos1() const { return *cur1=='\0'; }
      bool eos2() const { return *cur2=='\0'; }
      
    protected:
      const char* beg1;
      const char* beg2;
      const char* cur1;
      const char* cur2;
    };

    class CharStreamForComposition : public CompoundCharStream {
    public:
      CharStreamForComposition (const char* first, const char* second, 
				const std::vector<unsigned char>& canonical_classes, 
				std::string& buf)
	: CompoundCharStream(first, second), classes(canonical_classes), skipped(buf) 
      {}
      
      void init_skipinfo() { 
	skipped.clear();
	skipped_tail = 0;
      }

      void mark_as_last_valid_point() {
	skipped_tail = skipped.size();
	marked_point = cur();
      }

      void reset_at_marked_point() {
	setCur(marked_point);
      }

      void append_read_char_to_str(std::string& s, const char* beg) const {
	if(eos1()==false) {
	  s.append(beg, cur());
	} else {
	  s.append(beg,  cur1);
	  s.append(beg2, cur());
	}
      }

      void append_skipped_chars_to_str(std::string& s) const {
	s.append(skipped.begin(), skipped.begin()+skipped_tail);
      }

      unsigned char get_canonical_class() const { 
	return offset() < classes.size() ? classes[offset()] : 0;
      }
      
      bool next_combining_char(unsigned char prev_class, const char* ppp) {
	while(Util::is_utf8_char_start_byte(peek()) == false)
	  read();
	
	unsigned char mid_class = get_prev_canonical_class();
	unsigned char cur_class = get_canonical_class();
	
	if(prev_class==0 && mid_class==0 && cur_class!=0)
	  return false;

	if(prev_class < cur_class && mid_class < cur_class) {
	  skipped.append(ppp, cur());
	  return true;
	} else {
	  if(cur_class != 0) {
	    read();
	    return next_combining_char(prev_class,ppp);
	  }
	  return false;
	}
      }

    private:
      unsigned char get_prev_canonical_class() const { 
	return offset()-1 < classes.size() ? classes[offset()-1] : 0;
      }

    private:
      const std::vector<unsigned char>& classes;
      std::string& skipped;
      unsigned skipped_tail;
      const char* marked_point;
    };
  }
}

#endif
