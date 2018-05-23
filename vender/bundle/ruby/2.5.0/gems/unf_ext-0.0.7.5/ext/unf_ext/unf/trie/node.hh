#ifndef UNF_TRIE_NODE_HH
#define UNF_TRIE_NODE_HH

namespace UNF {
  namespace Trie {
    class Node {
    public:
      unsigned jump(unsigned char ch) const { return base() + ch; }
      unsigned value() const { return base(); }
      unsigned check_char() const { return data>>24; }
      unsigned to_uint() const { return data; }

      static const Node* from_uint_array(const unsigned* node_uints)
      { return reinterpret_cast<const Node*>(node_uints); }

    private:
      unsigned base() const { return data & 0xFFFFFF; }

    private:
      unsigned data;
    };
  }
}

#endif
