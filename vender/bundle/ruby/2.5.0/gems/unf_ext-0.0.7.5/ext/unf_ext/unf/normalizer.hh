#ifndef UNF_NORMALIZER_HH
#define UNF_NORMALIZER_HH

#include <vector>
#include <string>
#include <algorithm>
#include <cstring>
#include "trie/searcher.hh"
#include "trie/char_stream.hh"
#include "table.hh"
#include "util.hh"

namespace UNF {
  class Normalizer {
  public:
    enum Form { FORM_NFD, FORM_NFC, FORM_NFKD, FORM_NFKC };

  public:
    Normalizer()
      : nf_d(TABLE::NODES, TABLE::CANONICAL_DECOM_ROOT, (const char *)TABLE::STRINGS),
	nf_kd(TABLE::NODES, TABLE::COMPATIBILITY_DECOM_ROOT, (const char *)TABLE::STRINGS),
	nf_c(TABLE::NODES, TABLE::CANONICAL_COM_ROOT, (const char *)TABLE::STRINGS),
	nf_c_qc(TABLE::NODES, TABLE::NFC_ILLEGAL_ROOT),
	nf_kc_qc(TABLE::NODES, TABLE::NFKC_ILLEGAL_ROOT),
	ccc(TABLE::NODES, TABLE::CANONICAL_CLASS_ROOT)
    {}

    const char* normalize(const char* src, Form form) {
      switch(form) {
      case FORM_NFD:  return nfd(src);
      case FORM_NFC:  return nfc(src);
      case FORM_NFKD: return nfkd(src);
      case FORM_NFKC: return nfkc(src);
      default:        return src;
      }
    }
    const char* nfd(const char* src)  { return decompose(src, nf_d); }
    const char* nfkd(const char* src) { return decompose(src, nf_kd); }
    const char* nfc(const char* src)  { return compose(src, nf_c_qc, nf_d); }
    const char* nfkc(const char* src) { return compose(src, nf_kc_qc, nf_kd); }

  private:
    const char* decompose(const char* src, const Trie::NormalizationForm& nf) {
      const char* beg = next_invalid_char(src, nf);
      if(*beg=='\0')
	return src;
      
      buffer.assign(src, beg);
      do {
	const char* end = next_valid_starter(beg, nf);
	decompose_one(beg, end, nf, buffer);
	beg = next_invalid_char(end, nf);
	buffer.append(end, beg);
      } while(*beg!='\0');
      
      return buffer.c_str();      
    }

    void decompose_one(const char* beg, const char* end, const Trie::NormalizationForm& nf, std::string& buf) {
      unsigned last = buf.size();
      nf.decompose(Trie::RangeCharStream(beg,end), buf);
      char* bufbeg = const_cast<char*>(buf.data());
      canonical_combining_class_ordering(bufbeg+last, bufbeg+buf.size());
    }

    const char* compose(const char* src, const Trie::NormalizationForm& nf, const Trie::NormalizationForm& nf_decomp) {
      const char* beg = next_invalid_char(src, nf);
      if(*beg=='\0')
	return src;
      
      buffer.assign(src, beg);
      while(*beg!='\0') {
	const char* end = next_valid_starter(beg, nf);
	buffer2.clear();
	decompose_one(beg, end, nf_decomp, buffer2);
	end = compose_one(buffer2.c_str(), end, buffer);
	beg = next_invalid_char(end, nf);
	buffer.append(end, beg);
      }

      return buffer.c_str();      
    }

    const char* compose_one(const char* starter, const char* rest_starter, std::string& buf) {
      Trie::CharStreamForComposition in(starter, rest_starter, canonical_classes, buffer3);
      while(in.within_first())
	nf_c.compose(in, buf);
      return in.cur();
    }

    void canonical_combining_class_ordering(char* beg, const char* end) {
      canonical_classes.assign(end-beg+1, 0); // +1 is for sentinel value
      ccc.sort(beg, canonical_classes);
    }

    const char* next_invalid_char(const char* src, const Trie::NormalizationForm& nf) const {
      int last_canonical_class = 0;
      const char* cur = Util::nearest_utf8_char_start_point(src);
      const char* starter = cur;
      
      for(; *cur != '\0'; cur = Util::nearest_utf8_char_start_point(cur+1)) {
	int canonical_class = ccc.get_class(cur);
	if(last_canonical_class > canonical_class && canonical_class != 0)
	  return starter;

	if(nf.quick_check(cur)==false)
	  return starter;

	if(canonical_class==0)
	  starter=cur;

	last_canonical_class = canonical_class;
      }
      return cur;
    }

    const char* next_valid_starter(const char* src, const Trie::NormalizationForm& nf) const {
      const char* cur = Util::nearest_utf8_char_start_point(src+1);
      while(ccc.get_class(cur)!=0 || nf.quick_check(cur)==false)
	cur = Util::nearest_utf8_char_start_point(cur+1);
      return cur;
    }

  private:
    const Trie::NormalizationForm nf_d;
    const Trie::NormalizationForm nf_kd;
    const Trie::NormalizationForm nf_c;
    const Trie::NormalizationForm nf_c_qc;
    const Trie::NormalizationForm nf_kc_qc;
    const Trie::CanonicalCombiningClass ccc;
    
    std::string buffer;
    std::string buffer2;
    std::string buffer3;
    std::vector<unsigned char> canonical_classes;
  };
}

#endif
