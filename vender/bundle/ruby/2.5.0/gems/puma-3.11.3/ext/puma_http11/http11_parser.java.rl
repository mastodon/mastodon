package org.jruby.puma;

import org.jruby.util.ByteList;

public class Http11Parser {

/** Machine **/

%%{

  machine puma_parser;

  action mark {parser.mark = fpc; }

  action start_field { parser.field_start = fpc; }
  action snake_upcase_field { /* FIXME stub */ }
  action write_field { 
    parser.field_len = fpc-parser.field_start;
  }

  action start_value { parser.mark = fpc; }
  action write_value { 
    if(parser.http_field != null) {
      parser.http_field.call(parser.data, parser.field_start, parser.field_len, parser.mark, fpc-parser.mark);
    }
  }
  action request_method { 
    if(parser.request_method != null) 
      parser.request_method.call(parser.data, parser.mark, fpc-parser.mark);
  }
  action request_uri { 
    if(parser.request_uri != null)
      parser.request_uri.call(parser.data, parser.mark, fpc-parser.mark);
  }
  action fragment { 
    if(parser.fragment != null)
      parser.fragment.call(parser.data, parser.mark, fpc-parser.mark);
  }
  
  action start_query {parser.query_start = fpc; }
  action query_string { 
    if(parser.query_string != null)
      parser.query_string.call(parser.data, parser.query_start, fpc-parser.query_start);
  }

  action http_version {	
    if(parser.http_version != null)
      parser.http_version.call(parser.data, parser.mark, fpc-parser.mark);
  }

  action request_path {
    if(parser.request_path != null)
      parser.request_path.call(parser.data, parser.mark, fpc-parser.mark);
  }

  action done { 
    parser.body_start = fpc + 1; 
    if(parser.header_done != null)
      parser.header_done.call(parser.data, fpc + 1, pe - fpc - 1);
    fbreak;
  }

  include puma_parser_common "http11_parser_common.rl";

}%%

/** Data **/
%% write data;

   public static interface ElementCB {
     public void call(Object data, int at, int length);
   }

   public static interface FieldCB {
     public void call(Object data, int field, int flen, int value, int vlen);
   }

   public static class HttpParser {
      int cs;
      int body_start;
      int content_len;
      int nread;
      int mark;
      int field_start;
      int field_len;
      int query_start;

      Object data;
      ByteList buffer;

      public FieldCB http_field;
      public ElementCB request_method;
      public ElementCB request_uri;
      public ElementCB fragment;
      public ElementCB request_path;
      public ElementCB query_string;
      public ElementCB http_version;
      public ElementCB header_done;

      public void init() {
          cs = 0;

          %% write init;

          body_start = 0;
          content_len = 0;
          mark = 0;
          nread = 0;
          field_len = 0;
          field_start = 0;
      }
   }

   public final HttpParser parser = new HttpParser();

   public int execute(ByteList buffer, int off) {
     int p, pe;
     int cs = parser.cs;
     int len = buffer.length();
     assert off<=len : "offset past end of buffer";

     p = off;
     pe = len;
     // get a copy of the bytes, since it may not start at 0
     // FIXME: figure out how to just use the bytes in-place
     byte[] data = buffer.bytes();
     parser.buffer = buffer;

     %% write exec;

     parser.cs = cs;
     parser.nread += (p - off);
     
     assert p <= pe                  : "buffer overflow after parsing execute";
     assert parser.nread <= len      : "nread longer than length";
     assert parser.body_start <= len : "body starts after buffer end";
     assert parser.mark < len        : "mark is after buffer end";
     assert parser.field_len <= len  : "field has length longer than whole buffer";
     assert parser.field_start < len : "field starts after buffer end";

     return parser.nread;
   }

   public int finish() {
    if(has_error()) {
      return -1;
    } else if(is_finished()) {
      return 1;
    } else {
      return 0;
    }
  }

  public boolean has_error() {
    return parser.cs == puma_parser_error;
  }

  public boolean is_finished() {
    return parser.cs == puma_parser_first_final;
  }
}
