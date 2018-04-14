package http_parser.lolevel;

import java.nio.*;
import java.util.*;

import primitive.collection.ByteList;

import http_parser.*;

public class Util {

  static final ParserSettings SETTINGS_NULL = new ParserSettings();

  static String str (ByteBuffer b, int pos, int len) {
    byte [] by = new byte[len];
    int saved = b.position();
    b.position(pos);
    b.get(by);
    b.position(saved);
    return new String(by);
  }
  static String str (ByteBuffer b) {
    int len = b.limit() - b.position(); 
    byte [] by = new byte[len];
    int saved = b.position();
    b.get(by);
    b.position(saved);
    return new String(by);
  }

  static ByteBuffer buffer(String str) {
    return ByteBuffer.wrap(str.getBytes());
  }

  static ByteBuffer empty() {
    return ByteBuffer.wrap(new byte[0]);
  }

  static void check(boolean betterBtrue) {
    if (!betterBtrue) {
      throw new RuntimeException("!");
    }
  }
  static void check (int should, int is) {
    if (should != is) {
      throw new RuntimeException("should be: "+should+" is:"+is);
    }
  }

  static void test_message(Message mes) {
    int raw_len = mes.raw.length;
    for (int msg1len = 0; msg1len != raw_len; ++msg1len) {
      mes.reset();
      ByteBuffer msg1 = ByteBuffer.wrap(mes.raw, 0, msg1len);
      ByteBuffer msg2 = ByteBuffer.wrap(mes.raw, msg1len, mes.raw.length - msg1len);

      HTTPParser parser = new HTTPParser(mes.type);
      ParserSettings settings = mes.settings();

      int read = 0;
      if (msg1len !=0) {
        read = parser.execute(settings, msg1);
        if (mes.upgrade() && parser.upgrade) {
          // Messages have a settings() that checks itself...
          check(1 == mes.num_called);
          continue; 
        }
        check(read == msg1len);
      }

      read = parser.execute(settings, msg2);
      if (mes.upgrade() && parser.upgrade) {
        check(1 == mes.num_called);
        continue; 
      }

      check( mes.raw.length - msg1len, read);
      
      ByteBuffer empty = Util.empty();
      read = parser.execute(settings, empty);
      
      if (mes.upgrade() && parser.upgrade) {
        check(1 == mes.num_called);
        continue;
      }
      check(empty.position() == empty.limit());
      check(0 == read);
      check(1 == mes.num_called);

    }
  }

  static void test_multiple3(Message r1, Message r2, Message r3) {
    int message_count = 1;
    if (!r1.upgrade()) {
      message_count++;
      if (!r2.upgrade()) {
        message_count++;
      }
    }
    boolean has_upgrade = (message_count < 3 || r3.upgrade());

    ByteList blist = new ByteList();
    blist.addAll(r1.raw);
    blist.addAll(r2.raw);
    blist.addAll(r3.raw);

    byte [] raw = blist.toArray();
    ByteBuffer buf   = ByteBuffer.wrap(raw);

    Util.Settings settings = Util.settings(); 
    HTTPParser parser = new HTTPParser(r1.type);
    
    int read = parser.execute(settings, buf);
    if (has_upgrade && parser.upgrade) {
      raw = upgrade_message_fix(raw, read, r1,r2,r3);
      check(settings.numCalled == message_count); 
      return;
    }

    check(read == raw.length);

    buf = Util.empty();    
    read = parser.execute(settings, buf);
    if (has_upgrade && parser.upgrade) {
      check(settings.numCalled == message_count); 
      return;
    }

    check(0 == read);
    check(settings.numCalled == message_count);
  }  

  /* Given a sequence of bytes and the number of these that we were able to
   * parse, verify that upgrade bodies are correct.
   */
  static byte [] upgrade_message_fix(byte[] body, int nread, Message... msgs) {
    int off = 0;
    for (Message m : msgs) {
      off += m.raw.length;
      if (m.upgrade()) {
        off -= m.upgrade.length;
        // Original C:
        //     Check the portion of the response after its specified upgrade 
        //     if (!check_str_eq(m, "upgrade", body + off, body + nread)) {
        //       abort();
        //     }
        // to me, this seems to be equivalent to comparing off and nread ...
        check (off, nread);
        
        // Original C:
        //   Fix up the response so that message_eq() will verify the beginning
        //   of the upgrade */
        // 
        //   *(body + nread + strlen(m->upgrade)) = '\0';
        // This only shortens body so the strlen check passes.
        return new byte[off];

      }
    }
    return null;
  }
//upgrade_message_fix(char *body, const size_t nread, const size_t nmsgs, ...) {
//  va_list ap;
//  size_t i;
//  size_t off = 0;
// 
//  va_start(ap, nmsgs);
//
//  for (i = 0; i < nmsgs; i++) {
//    struct message *m = va_arg(ap, struct message *);
//
//    off += strlen(m->raw);
//
//    if (m->upgrade) {
//      off -= strlen(m->upgrade);
//
//      /* Check the portion of the response after its specified upgrade */
//      if (!check_str_eq(m, "upgrade", body + off, body + nread)) {
//        abort();
//      }
//
//      /* Fix up the response so that message_eq() will verify the beginning
//       * of the upgrade */
//      *(body + nread + strlen(m->upgrade)) = '\0';
//      messages[num_messages -1 ].upgrade = body + nread;
//
//      va_end(ap);
//      return;
//    }
//  }
//
//  va_end(ap);
//  printf("\n\n*** Error: expected a message with upgrade ***\n");
//
//  abort();
//}
  static void p (Object o) {
    System.out.println(o);
  }

  static Settings settings() {
    return new Settings();
  }
  static Message find(List<Message> list, String name) {
    for (Message m : list) {
      if (name.equals(m.name)) {
        return m;
      }
    }
    return null;
  }

  static class Settings extends ParserSettings {
    public int numCalled;
    public int bodyCount;
    Settings() {
      this.on_message_complete = new HTTPCallback() {
        public int cb (HTTPParser parser) {
          numCalled++;
          return 0;
        }
      };
      this.on_body = new HTTPDataCallback() {
        public int cb (HTTPParser p, ByteBuffer b, int pos, int len) {
          bodyCount += len;
          return 0;
        }
      }; 
    }
    
    int numCalled () {
      return this.numCalled;
    }
  }
}
