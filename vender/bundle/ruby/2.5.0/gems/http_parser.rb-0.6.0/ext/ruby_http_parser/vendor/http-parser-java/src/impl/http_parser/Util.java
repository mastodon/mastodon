package http_parser;

import java.nio.ByteBuffer;

public class Util {
//  public static String toString(http_parser.lolevel.HTTPParser p) {
//    StringBuilder builder = new StringBuilder();
//    
//    // the stuff up to the break is ephermeral and only meaningful
//    // while the parser is parsing. In general, this method is 
//    // probably only useful during debugging.
//
//    builder.append("state :"); builder.append(p.state); builder.append("\n");
//    builder.append("header_state :"); builder.append(p.header_state); builder.append("\n");
//    builder.append("strict :"); builder.append(p.strict); builder.append("\n");
//    builder.append("index :"); builder.append(p.index); builder.append("\n");
//    builder.append("flags :"); builder.append(p.flags); builder.append("\n");
//    builder.append("nread :"); builder.append(p.nread); builder.append("\n");
//    builder.append("content_length :"); builder.append(p.content_length); builder.append("\n");
//
//
//    builder.append("type :"); builder.append(p.type); builder.append("\n");
//    builder.append("http_major :"); builder.append(p.http_major); builder.append("\n");
//    builder.append("http_minor :"); builder.append(p.http_minor); builder.append("\n");
//    builder.append("status_code :"); builder.append(p.status_code); builder.append("\n");
//    builder.append("method :"); builder.append(p.method); builder.append("\n");
//    builder.append("upgrade :"); builder.append(p.upgrade); builder.append("\n");
//
//    return builder.toString();
//
//  }

  public static String error (String mes, ByteBuffer b, int beginning) {
      // the error message should look like this:
      //
      // Bla expected something, but it's not there (mes)
      // GEt / HTTP 1_1
      // ............^.
      //
      // |----------------- 72 -------------------------|

      // This is ridiculously complicated and probably riddled with
      // off-by-one errors, should be moved into high level interface.
      // TODO.
      
      // also: need to keep track of the initial buffer position in
      // execute so that we don't screw up any `mark()` that may have
      // been set outside of our control to be nice.

      final int mes_width = 72;
      int p   = b.position();      // error position
      int end = b.limit();         // this is the end
      int m   = end - beginning;    // max mes length
      
      StringBuilder builder = new StringBuilder();
      int p_adj = p;

      byte [] orig = new byte[0];
      if (m <= mes_width) {
        orig = new byte[m];
        b.position(beginning);
        b.get(orig, 0, m);
        p_adj = p-beginning;
        
        
      } else {
        // we'll need to trim bit off the beginning and/or end
        orig = new byte[mes_width];
        // three possibilities:
        // a.) plenty of stuff around p
        // b.) plenty of stuff in front of p
        // c.) plenty of stuff behind p
        // CAN'T be not enough stuff aorund p in total, because 
        // m>meswidth (see if to this else)

        int before = p-beginning;
        int after  = end - p;
        if ( (before > mes_width/2) && (after > mes_width/2)) {
          // plenty of stuff in front of and behind error
          p_adj = mes_width/2;
          b.position(p - mes_width/2);
          b.get(orig, 0, mes_width);
        } else if  (before <= mes_width/2) {
          // take all of the begining.
          b.position(beginning);
          // and as much of the rest as possible
          
          b.get(orig, 0, mes_width);

        } else {
          // plenty of stuff before
          before = end-mes_width;
          b.position(before);
          p_adj = p - before;
          b.get(orig, 0, mes_width);
        }
      }

      builder.append(new String(orig));
      builder.append("\n");
      for (int i = 0; i!= p_adj; ++i) {
        builder.append(".");
      }
      builder.append("^");


      b.position(p); // restore position
      return builder.toString();

  }
}
