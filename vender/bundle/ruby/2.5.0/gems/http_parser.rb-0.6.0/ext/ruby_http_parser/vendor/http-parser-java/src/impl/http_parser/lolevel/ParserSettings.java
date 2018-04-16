package http_parser.lolevel;
import java.nio.ByteBuffer;
import http_parser.HTTPException;
public class ParserSettings {

  public HTTPCallback       on_message_begin;
  public HTTPDataCallback 	on_path;
  public HTTPDataCallback 	on_query_string;
  public HTTPDataCallback 	on_url;
  public HTTPDataCallback 	on_fragment;
  public HTTPCallback       on_status_complete;
  public HTTPDataCallback 	on_header_field;
  public HTTPDataCallback 	on_header_value;
  public HTTPCallback       on_headers_complete;
  public HTTPDataCallback 	on_body;
  public HTTPCallback       on_message_complete;
  public HTTPErrorCallback  on_error;

	void call_on_message_begin (HTTPParser p) {
		call_on(on_message_begin, p);
	}

	void call_on_message_complete (HTTPParser p) {
		call_on(on_message_complete, p);
	}

  // this one is a little bit different:
  // the current `position` of the buffer is the location of the
  // error, `ini_pos` indicates where the position of
  // the buffer when it was passed to the `execute` method of the parser, i.e.
  // using this information and `limit` we'll know all the valid data
  // in the buffer around the error we can use to print pretty error
  // messages.
  void call_on_error (HTTPParser p, String mes, ByteBuffer buf, int ini_pos) {
    if (null != on_error) {
      on_error.cb(p, mes, buf, ini_pos);
      return;
    }
    // if on_error gets called it MUST throw an exception, else the parser
    // will attempt to continue parsing, which it can't because it's
    // in an invalid state.
    throw new HTTPException(mes);
	}

	void call_on_header_field (HTTPParser p, ByteBuffer buf, int pos, int len) {
		call_on(on_header_field, p, buf, pos, len);
	}
	void call_on_query_string (HTTPParser p, ByteBuffer buf, int pos, int len) {
		call_on(on_query_string, p, buf, pos, len);
	}
	void call_on_fragment (HTTPParser p, ByteBuffer buf, int pos, int len) {
		call_on(on_fragment, p, buf, pos, len);
	}
  void call_on_status_complete(HTTPParser p) {
    call_on(on_status_complete, p);
  }
	void call_on_path (HTTPParser p, ByteBuffer buf, int pos, int len) {
		call_on(on_path, p, buf, pos, len);
	}
	void call_on_header_value (HTTPParser p, ByteBuffer buf, int pos, int len) {
		call_on(on_header_value, p, buf, pos, len);
	}
	void call_on_url (HTTPParser p, ByteBuffer buf, int pos, int len) {
		call_on(on_url, p, buf, pos, len);
	}
	void call_on_body(HTTPParser p, ByteBuffer buf, int pos, int len) {
		call_on(on_body, p, buf, pos, len);
	}
	void call_on_headers_complete(HTTPParser p) {
		call_on(on_headers_complete, p);
	}
	void call_on (HTTPCallback cb, HTTPParser p) {
		// cf. CALLBACK2 macro
		if (null != cb) {
			cb.cb(p);
		}
	}
	void call_on (HTTPDataCallback cb, HTTPParser p, ByteBuffer buf, int pos, int len) {
		if (null != cb && -1 != pos) {
			cb.cb(p,buf,pos,len);
		}
	}
}
