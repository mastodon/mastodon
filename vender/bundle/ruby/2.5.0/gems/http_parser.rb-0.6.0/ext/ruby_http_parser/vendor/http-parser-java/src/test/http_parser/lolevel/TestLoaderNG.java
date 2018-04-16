package http_parser.lolevel;
// name  : 200 trailing space on chunked body
// raw   : "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nTransfer-Encoding: chunked\r\n\r\n25  \r\nThis is the data in the first chunk\r\n\r\n1C\r\nand this is the second one\r\n\r\n0  \r\n\r\n"
// type  : HTTP_RESPONSE
// method: HTTP_DELETE
// status code :200
// request_path:
// request_url :
// fragment    :
// query_string:
// body        :"This is the data in the first chunk\r\nand this is the second one\r\n"
// body_size   :65
// header_0 :{ "Content-Type": "text/plain"}
// header_1 :{ "Transfer-Encoding": "chunked"}
// should_keep_alive         :1
// upgrade                   :0
// http_major                :1
// http_minor                :1


import java.io.FileReader;
import java.io.BufferedReader;
import java.io.StringReader;
import java.io.Reader;
import java.io.Reader;
import java.io.IOException;

import java.util.*;
import java.util.regex.*;

import java.nio.ByteBuffer;

import http_parser.HTTPMethod;
import http_parser.ParserType;

public class TestLoaderNG {
  String fn;
  public TestLoaderNG(String filename) {
    this.fn = filename;
  }
  static void p(Object o) {
    System.out.println(o);
  }
  public static List<Message> load (String fn) {
    List<Message> list = null;
    try {
      BufferedReader buf = new BufferedReader(new FileReader(fn));
      list = load(buf);
    } catch (Throwable t) {
      throw new RuntimeException(t);
    }
      return list;

  }
  public static Message parse (String message) {
    List<Message> list = load(new BufferedReader(new StringReader(message)));  
    if (null == list || 0 == list.size() ) {
      return null;
    } 
    return list.get(0);
  }

  public static List<Message> load (BufferedReader buf) {
    List<Message>    list = new LinkedList<Message>();
    String        line = null;
    Message          curr = new Message();
    Pattern    pattern = Pattern.compile("(\\S+)\\s*:(.*)");
    try {
      while (null != (line = buf.readLine()) ){
        if ("".equals(line.trim())) {
          list.add (curr);
          curr = new Message();
          continue;
        }
        Matcher m = pattern.matcher(line);
        if (m.matches()) {
          // you can not be fucking serious!?
          // this has got to be the most retarded regex 
          // interface in the history of the world ...
          // (though I'm sure there's worse c++ regexp libs...)
          MatchResult r = m.toMatchResult();
          String    key = r.group(1).trim();
          String  value = r.group(2).trim();
               if ("name".equals(key))         {curr.name = value;}
          else if ("raw".equals(key))          {curr.raw = toByteArray(value);} //!
          else if ("type".equals(key))         {curr.type = ParserType.parse(value);}
          else if ("method".equals(key))       {curr.method = HTTPMethod.parse(value);}
          else if ("status_code".equals(key))  {curr.status_code = Integer.parseInt(value);}
          else if ("request_path".equals(key)) {curr.request_path = value;}
          else if ("request_url".equals(key))  {curr.request_url = value;}

          else if ("fragment".equals(key))     {curr.fragment = value;}
          else if ("query_string".equals(key)) {curr.query_string = value;}
          else if ("body".equals(key))         {curr.body = toByteArray(value);} //!
          else if ("body_size".equals(key))    {curr.body_size = Integer.parseInt(value);}
          else if (key.startsWith("header"))   {
            String [] h = getHeader(value); 
            curr.header.put(h[0], h[1]);
          } 
          else if ("should_keep_alive".equals(key)) 
          {curr.should_keep_alive = (1 == Integer.parseInt(value));}
          else if ("upgrade".equals(key))      { curr.upgrade = toByteArray(value);}
          else if ("http_major".equals(key))   {curr.http_major = Integer.parseInt(value);}
          else if ("http_minor".equals(key))   {curr.http_minor = Integer.parseInt(value);}
        } else {
          p("WTF?"+line);
        }

      }
    } catch (Throwable t) {
      throw new RuntimeException(t);
    }
    return list;
  }

  static String [] getHeader(String value) {
    // { "Host": "0.0.0.0=5000"}
    Pattern p = Pattern.compile("\\{ ?\"([^\"]*)\": ?\"(.*)\"}");
    Matcher m = p.matcher(value);
    if (!m.matches()) {
      p(value);
      throw new RuntimeException("something wrong");
    }
    String [] result = new String[2];
    MatchResult r = m.toMatchResult();
    result[0] = r.group(1).trim();
    result[1] = r.group(2); //.trim();
    return result;
  }

  static final byte BSLASH = 0x5c;
  static final byte QUOT   = 0x22;
  static final byte CR     = 0x0d;
  static final byte LF     = 0x0a;
  static final byte n      = 0x6e;
  static final byte r      = 0x72;

  static final Byte[] JAVA_GENERICS_ROCK_HARD = new Byte[0];


  static byte [] toByteArray (String quotedString) {
    ArrayList<Byte> bytes = new ArrayList<Byte>();
    String s = quotedString.substring(1, quotedString.length()-1);
    byte [] byts = s.getBytes(java.nio.charset.Charset.forName("UTF8"));
    boolean escaped = false;
    for (byte b : byts) {
      switch (b) {
        case BSLASH:
          escaped = true;
          break;
        case n:
          if (escaped) {
            bytes.add(LF);
            escaped = false;
          } else {
            bytes.add(b);
          }
          break;
        case r:
          if (escaped) {
            escaped = false;
            bytes.add(CR);
          } else {
            bytes.add(b);
          }
          break;
        case QUOT:
          escaped = false;
          bytes.add(QUOT);
          break;
        default:
          bytes.add(b);
      }

    }

    byts = new byte[bytes.size()];
    int i = 0;
    for (Byte b : bytes) {
      byts[i++]=b;
    }
    return byts;
  }

  public static void main(String [] args) throws Throwable {
    //TestLoaderNG  l = new TestLoaderNG(args[0]);
    List<Message> ts = load(args[0]);
    for (Message t : ts) {
//      for (int i =0; i!= t.raw.length; ++i) {
//        p(i+":"+t.raw[i]);
//      }
//      try {
      t.execute_permutations();
//      } catch (Throwable th) {
//        p("failed: "+t.name);
//      }
      t.execute();
      //	System.exit(0);
    }
  }

  class Header {
    String field;
    String value;
  }
  enum LastHeader {
    NONE
      ,FIELD
      ,VALUE
  }

}
