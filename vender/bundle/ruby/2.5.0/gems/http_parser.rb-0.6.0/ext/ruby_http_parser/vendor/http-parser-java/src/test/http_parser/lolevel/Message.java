package http_parser.lolevel;

import java.nio.*;
import java.io.*;
import java.util.*;

import http_parser.HTTPMethod;
import http_parser.HTTPParserUrl;
import http_parser.ParserType;
import http_parser.lolevel.TestLoaderNG.Header;
import http_parser.lolevel.TestLoaderNG.LastHeader;

import primitive.collection.ByteList;

import static http_parser.lolevel.Util.str;

public class Message {
  String name; 
  byte [] raw; 
  ParserType type; 
  HTTPMethod method;
  int status_code;
  String request_path; // byte [] ?
  String request_url;
  String fragment ;
  String query_string;
  byte [] body;
  int body_size;
  int num_headers;
  LastHeader last_header_element;
  Map<String,String> header;
  List<Header> headers;
  boolean should_keep_alive;

  byte[] upgrade;
  boolean upgrade() {
    return null != upgrade;
  }

  int http_major;
  int http_minor;

  boolean message_begin_called;
  boolean headers_complete_called;
  boolean message_complete_called;
  boolean message_complete_on_eof;
  

  Map<String,String> parsed_header;
  String currHField;
  String currHValue;
  byte [] pbody;
  int num_called;

  public String toString() {
    StringBuilder b = new StringBuilder();
    b.append("NAME: "); b.append(name);b.append("\n");
    b.append("type: "); b.append(type);b.append("\n");
    b.append("method: "); b.append(method);b.append("\n");
    b.append("status_code: "); b.append(status_code);b.append("\n");
    b.append("request_path: "); b.append(request_path);b.append("\n");
    b.append("request_url: "); b.append(request_url);b.append("\n");
    b.append("fragment: "); b.append(fragment);b.append("\n");
    b.append("query_string: "); b.append(query_string);b.append("\n");
    b.append("body:\n"); b.append(new String(body));b.append("\n");
    b.append("should_keep_alive: "); b.append(should_keep_alive);b.append("\n");
    b.append("upgrade: "); b.append(upgrade);b.append("\n");
    b.append("http_major: "); b.append(http_major);b.append("\n");
    b.append("http_minor: "); b.append(http_minor);b.append("\n");
    b.append("message_complete_called: "); b.append(message_complete_called);b.append("\n");
    return b.toString();
  }

  Message () {
    this.header        = new HashMap<String, String>();
    this.headers = new LinkedList<Header>();
    reset();
  }
  /*
   *prepare this Test Instance for reuse.
   * */
  void reset () {
    this.parsed_header = new HashMap<String, String>();
    this.pbody         = null;
    this.num_called    = 0;

  }
  void check (boolean val, String mes) {
    if (!val) {
      //p(name+" : "+mes);
      throw new RuntimeException(name+" : "+mes);
    }
  }


  HTTPDataCallback getCB (final String value, final String mes, final TestSettings settings) {
    return new HTTPDataCallback() {
      public int cb (HTTPParser p, ByteBuffer b, int pos, int len){
        //   if ("url".equals(mes)){
        //    p("pos"+pos);
        //    p("len"+len);
        //    if (8==pos && 5 == len && "connect request".equals(name)) {
        //      //throw new RuntimeException(name);
        //    }
        //   }
        //String str    = str(b, pos, len);
        ByteList list = settings.map.get(mes);
        for (int i=0; i!=len; ++i) {
          list.add(b.get(pos+i));
        }
        //settings.map.put(mes, prev_val + str);
        //check(value.equals(str), "incorrect "+mes+": "+str);
        if (-1 == pos) {
          throw new RuntimeException("he?");
        }
        return 0;
      }
    };
  }

  void execute () {
    p(name);
    ByteBuffer   buf = ByteBuffer.wrap(raw);
    HTTPParser     p = new HTTPParser();
    TestSettings s = settings();



    p.execute(s, buf);
    if (!p.upgrade) {
      // call execute again, else parser can't know message is done
      // if no content length is set.
      p.execute(s, buf);
    }
    if (!s.success) {
      throw new RuntimeException("Test: "+name+" failed");
    }
  } // execute

  void execute_permutations() {
    /*
       |-|---------------|	
       |--|--------------|	
       |---|-------------|	
       (...)
       |---------------|-|	
       |-----------------|	
       */
    p(name);
    for (int i = 2; i != raw.length; ++i) {
       // p(i);
      HTTPParser   p = new HTTPParser();
      TestSettings s = settings();
      ByteBuffer buf = ByteBuffer.wrap(raw);
      int olimit = buf.limit();
      buf.limit(i);

      parse(p,s,buf);
      if (!p.upgrade) {
        buf.position(i);
        buf.limit(olimit);

        parse(p,s,buf);
        if (!p.upgrade) {
          parse(p,s,buf);
        } else {
          if (!upgrade()) {
            throw new RuntimeException("Test:"+name+"parsed as upgrade, is not");
          }
        }
      
      } else {
        if (!upgrade()) {
          throw new RuntimeException("Test:"+name+"parsed as upgrade, is not");
        }
      }
      if (!s.success) {
        p(this);
        throw new RuntimeException("Test: "+name+" failed");
      }
      reset();
    }
    //System.exit(0);
  } // execute_permutations
  void parse(HTTPParser p, ParserSettings s, ByteBuffer b) {
    //p("About to parse: "+b.position() + "->" + b.limit());
    p.execute(s, b);
  }

  TestSettings settings() {
    final TestSettings s = new TestSettings(); 
    s.on_url          = getCB(request_url,  "url", s);
    s.on_message_begin = new HTTPCallback() {
      public int cb (HTTPParser p) {
        message_begin_called = true;
        return -1;
      }
    };
    s.on_header_field = new HTTPDataCallback() {
      public int cb (HTTPParser p, ByteBuffer b, int pos, int len){
        if (null != currHValue && null == currHField) {
          throw new RuntimeException(name+": shouldn't happen");
        }
        if (null != currHField) {
          if (null == currHValue) {
            currHField += str(b,pos,len);
            return 0;
          } else {
            parsed_header.put(currHField, currHValue);
            currHField = null;
            currHValue = null;
          }
        }
        currHField = str(b,pos,len);
        return 0;
      }
    };
    s.on_header_value = new HTTPDataCallback() {
      public int cb (HTTPParser p, ByteBuffer b, int pos, int len){
        if (null == currHField) {
          throw new RuntimeException(name+" :shouldn't happen field");
        }
        if (null == currHValue) {
          currHValue = str(b,pos,len);
        } else {
          currHValue += str(b, pos, len);
        }
        return 0;
      }
    };
    s.on_headers_complete = new HTTPCallback() {
      public int cb (HTTPParser p) {
        headers_complete_called = true;
        String parsed_path  = null;
        String parsed_query = null;
        String parsed_url   = null;
        String parsed_frag  = null;
        
        try {
          parsed_url   = new String(s.map.get("url").toArray(),          "UTF8");

          HTTPParserUrl u = new HTTPParserUrl();
          HTTPParser pp = new HTTPParser();
          ByteBuffer data = Util.buffer(parsed_url);
          pp.parse_url(data,false, u);
          
          parsed_path  = u.getFieldValue(HTTPParser.UrlFields.UF_PATH, data);
          parsed_query = u.getFieldValue(HTTPParser.UrlFields.UF_QUERY, data);
          parsed_frag  = u.getFieldValue(HTTPParser.UrlFields.UF_FRAGMENT, data);

        } catch (java.io.UnsupportedEncodingException uee) {
          throw new RuntimeException(uee);
        }

        if (!request_path.equals(parsed_path)) {
          throw new RuntimeException(name+": invalid path: "+parsed_path+" should be: "+request_path);
        }
        if (!query_string.equals(parsed_query)) {
          throw new RuntimeException(name+": invalid query: "+parsed_query+" should be: "+query_string);
        }
        if (!request_url.equals(parsed_url)) {
          throw new RuntimeException(">"+name+"<: invalid url: >"+parsed_url+"< should be: >"+request_url+"<");
        }
        if (!fragment.equals(parsed_frag)) {
          throw new RuntimeException(name+": invalid fragement: "+parsed_frag+" should be: "+fragment);
        }
        if (null != currHValue || null != currHField) {
          if (null == currHField || null == currHValue) {
            throw new RuntimeException("shouldn't happen");
          }
        }
        if (null != currHField) {
          //p(currHField);
          //p(">"+currHValue+"<");
          parsed_header.put(currHField, currHValue);
          currHField = null;
          currHValue = null;
        }


        return 0;
      }
    };
    //	s.on_headers_complete = new HTTPCallback() {
    //		public int cb (HTTPParser p) {
    //			p("Complete:"+name);
    //			return 0;
    //		}
    //	};

    s.on_body = new HTTPDataCallback() {
      public int cb (HTTPParser p, ByteBuffer b, int pos, int len){
        int l   = pbody == null ? len : len + pbody.length;
        int off = pbody == null ?   0 : pbody.length;
        byte [] nbody = new byte[l];

        if (null != pbody) {
          System.arraycopy(pbody, 0, nbody, 0, pbody.length);
        }

        int saved = b.position();
        b.position(pos);
        b.get(nbody, off, len);
        b.position(saved);
        pbody = nbody;
        return 0;
      }
    };

    s.on_message_complete = new HTTPCallback() {
      public int cb(HTTPParser p) {
        message_complete_called = true;
        num_called += 1;
        if (   p.http_minor  != http_minor
            || p.http_major  != http_major
            || p.status_code != status_code ) {

          throw new RuntimeException("major/minor/status_code mismatch");
            }

        //check headers

        if (header.keySet().size() != parsed_header.keySet().size()) {
          p(parsed_header);
          throw new RuntimeException(name+": different amount of headers");
        }
        for (String key : header.keySet()) {
          String pvalue = parsed_header.get(key);
          if (!header.get(key).equals(pvalue)) {
            throw new RuntimeException(name+" : different values for :"+key+" is >"+pvalue+"< should: >"+header.get(key)+"<");
          }
        }
        //check body
        if (null == pbody && (null == body || body.length == 0 || body.length == 1)) {
          s.success = true;
          return 0;
        }
        if (null == pbody) {
          throw new RuntimeException(name+": no body, should be: "+new String(body));
        }
        if (pbody.length != body.length) {
          p(pbody.length);
          p(body.length);
          p(new String(pbody));
          p(new String(body));
          throw new RuntimeException(name+": incorrect body length");
        }
        for (int i = 0 ; i!= body.length; ++i) {
          if (pbody[i] != body[i]) {
            throw new RuntimeException("different body");
          }
        }
        s.success = true;
        return 0;
      }
    };
    return s;
  } // settings
  static void p(Object o) {
    System.out.println(o);
  }

  static class TestSettings extends ParserSettings {
    public boolean success;
    Map<String, ByteList> map;
    TestSettings () {
      map = new HashMap<String, ByteList>();
      map.put("path",         new ByteList());
      map.put("query_string", new ByteList());
      map.put("url",          new ByteList());
      map.put("fragment",     new ByteList());
    }
  }
}
