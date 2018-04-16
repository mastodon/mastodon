package http_parser.lolevel;

import java.nio.ByteBuffer;
import http_parser.HTTPException;
import http_parser.Util;

public class UnitTest {

	static void p(Object o) {System.out.println(o);}

  public static void testErrorFormat() {
    String bla = "This has an error in position 10 (the n in 'an')";
    ByteBuffer buf = ByteBuffer.wrap(bla.getBytes());
               buf.position(10); 
      
    String mes = 
"This has an error in position 10 (the n in 'an')\n" +
"..........^";

    check_equals(mes, Util.error ("test error", buf, 0)); 
   
    
    bla = "123456789A123456789B123456789C123456789D123456789E123456789F123456789G123456789H123456789I123456789J";
    buf = ByteBuffer.wrap(bla.getBytes());
    buf.position(50);
    mes = 
"56789B123456789C123456789D123456789E123456789F123456789G123456789H123456\n"+
"....................................^";
    check_equals(mes, Util.error("test trim right and left", buf, 0));


    buf.position(5);
    mes =
"123456789A123456789B123456789C123456789D123456789E123456789F123456789G12\n"+
".....^";
    check_equals(mes, Util.error("test trim right", buf, 0));
   

    int limit = buf.limit();
    buf.limit(10);
    mes = 
"123456789A\n"+
".....^";
    check_equals(mes,  Util.error("all before, not enough after", buf, 0));
        


    buf.limit(limit);
    buf.position(90);  
    mes = 
"9C123456789D123456789E123456789F123456789G123456789H123456789I123456789J\n"+
"..............................................................^";
    check_equals(mes, Util.error("test trim left", buf, 10));       
  }


  // Test that the error callbacks are properly called.
  public static void testErrorCallback () {
      String nothttp   = "THis is certainly not valid HTTP";
      ByteBuffer   buf = ByteBuffer.wrap(nothttp.getBytes());

      ParserSettings s = new ParserSettings();
                     s.on_error = new HTTPErrorCallback() {
        public void cb (HTTPParser p, String mes, ByteBuffer buf, int pos) {
          throw new HTTPException(mes);
        }          
                     }; // err callback
      

			HTTPParser     p = new HTTPParser();
      try {               
        p.execute(s, buf);
      } catch (HTTPException e) {
        check_equals("Invalid HTTP method", e.getMessage());
      }

      buf = ByteBuffer.wrap("GET / HTTP 1.10000".getBytes());
			  p = new HTTPParser();
      try {
        p.execute(s, buf);
      } catch (HTTPException e) {
        check_equals("ridiculous http minor", e.getMessage());
      }

      // if no error handler is defined, behave just like the above...
      ParserSettings s0 = new ParserSettings();
      
      buf = ByteBuffer.wrap("THis is certainly not valid HTTP".getBytes());
			  p = new HTTPParser();
      try {               
        p.execute(s0, buf);
      } catch (HTTPException e) {
        check_equals("Invalid HTTP method", e.getMessage());
      }

      buf = ByteBuffer.wrap("GET / HTTP 1.10000".getBytes());
			  p = new HTTPParser();
      try {
        p.execute(s0, buf);
      } catch (HTTPException e) {
        check_equals("ridiculous http minor", e.getMessage());
      }
  }

  static void check_equals(Object supposed2be, Object is) {
    if (!supposed2be.equals(is)) {
      throw new RuntimeException(is + " is supposed to be "+supposed2be);
    }
  }


  public static void test () {
    p(UnitTest.class);
    testErrorFormat();
    testErrorCallback();
  }  
}
