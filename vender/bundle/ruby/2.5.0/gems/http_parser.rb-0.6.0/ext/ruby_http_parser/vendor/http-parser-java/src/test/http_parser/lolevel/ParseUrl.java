package http_parser.lolevel;

import http_parser.HTTPParserUrl;
import static http_parser.lolevel.Util.*;

public class ParseUrl {
  public static void test(int i) {
    HTTPParserUrl u = new HTTPParserUrl();
    HTTPParser p = new HTTPParser();
    Url test = Url.URL_TESTS[i];
//    System.out.println(":: " + test.name);
    int rv = p.parse_url(Util.buffer(test.url),test.is_connect,u);
    UnitTest.check_equals(rv, test.rv);
    if(test.rv == 0){
      UnitTest.check_equals(u, test.u);
    }

  }
  public static void test() {
    p(ParseUrl.class);

    for (int i = 0; i < Url.URL_TESTS.length; i++) {
      test(i);      
    }
  }
  
  static void usage() {
    p("usage: [jre] http_parser.lolevel.ParseUrl [i]");
    p("             i : optional test case id");
    p("---------------------------------------------");
    p("Test Cases:");
    for (int i =0; i!= Url.URL_TESTS.length; ++i) {
      p(" "+i+": "+Url.URL_TESTS[i].name);
    }
  }

  public static void main (String [] args) {
    if (0 == args.length) {
      test();
    } else {
      try {
        int i = Integer.parseInt(args[0]);
        test(i);
      } catch (Throwable t) {
        t.printStackTrace();
        usage();
      }
    
    }
  }
}
