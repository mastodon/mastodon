package http_parser.lolevel;

import java.nio.*;
import java.util.*;

import static http_parser.lolevel.Util.*;
import http_parser.*;

import primitive.collection.ByteList;

public class Requests {
  
  static void test_simple(String req, boolean should_pass) {
    HTTPParser parser = new HTTPParser(ParserType.HTTP_REQUEST);
    ByteBuffer buf = buffer(req);
    boolean passed = false;
    int read = 0;
    try {
      parser.execute(Util.SETTINGS_NULL, buf);
      passed = (read == req.length());
      read = parser.execute(Util.SETTINGS_NULL, Util.empty());
      passed &= (0 == read);
    } catch (Throwable t) {
      passed = false;
    }
    check(passed == should_pass);
  }
  static void simple_tests() {
    test_simple("hello world", false);
    test_simple("GET / HTP/1.1\r\n\r\n", false);

    test_simple("ASDF / HTTP/1.1\r\n\r\n", false);
    test_simple("PROPPATCHA / HTTP/1.1\r\n\r\n", false);
    test_simple("GETA / HTTP/1.1\r\n\r\n", false);
  }

  public static void test () {
    p(Requests.class);    
    simple_tests();
    
    List<Message> all = TestLoaderNG.load("tests.dumped");
    List<Message> requests = new LinkedList<Message>();
    for (Message m : all) {
      if (ParserType.HTTP_REQUEST == m.type) {
        requests.add(m);
      }
    }
    for (Message m : requests) {
      test_message(m);
    }
    
    for (int i = 0; i!= requests.size(); ++i) {
      if (!requests.get(i).should_keep_alive) continue;
      for (int j = 0; j!=requests.size(); ++j) {
        if (!requests.get(j).should_keep_alive) continue;
        for (int k = 0; k!= requests.size(); ++k) {
          test_multiple3(requests.get(i), requests.get(j), requests.get(k));
        }
      }
    }
    
    // postpone test_scan

  }

  


}
