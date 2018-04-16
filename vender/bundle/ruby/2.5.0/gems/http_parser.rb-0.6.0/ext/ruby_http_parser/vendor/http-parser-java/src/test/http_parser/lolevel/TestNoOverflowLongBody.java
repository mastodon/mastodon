package http_parser.lolevel;

import java.nio.*;

import static http_parser.lolevel.Util.*;

public class TestNoOverflowLongBody {

  public static void test (http_parser.ParserType type, int len) {
    HTTPParser parser = new HTTPParser(type);
    ByteBuffer buf    = getBytes(type, len);
    
    int buflen = buf.limit();

    parser.execute(Util.SETTINGS_NULL, buf);

    check(buflen == buf.position());

    buf  = buffer("a");
    buflen  = buf.limit();
    
    for (int i = 0; i!= len; ++i) {
      parser.execute(Util.SETTINGS_NULL, buf);
      check(buflen == buf.position());
      buf.rewind();
    }
    
    buf = getBytes(type, len);
    buflen = buf.limit();

    parser.execute(Util.SETTINGS_NULL, buf);

    check(buflen == buf.position());

  }

  static ByteBuffer getBytes (http_parser.ParserType type, int length) {
    if (http_parser.ParserType.HTTP_BOTH == type) {
      throw new RuntimeException("only HTTP_REQUEST and HTTP_RESPONSE");
    }
    
    String template = "%s\r\nConnection: Keep-Alive\r\nContent-Length: %d\r\n\r\n";
    String str = null;
    if (http_parser.ParserType.HTTP_REQUEST == type) {
      str = String.format(template, "GET / HTTP/1.1", length); 
    } else {
      str = String.format(template, "HTTP/1.0 200 OK", length);
    }
    return buffer(str);
  }

  public static void test () {
    p(TestNoOverflowLongBody.class);
    test(http_parser.ParserType.HTTP_REQUEST, 1000);
    test(http_parser.ParserType.HTTP_REQUEST, 100000);
    test(http_parser.ParserType.HTTP_RESPONSE, 1000);
    test(http_parser.ParserType.HTTP_RESPONSE, 100000);
  }



}
