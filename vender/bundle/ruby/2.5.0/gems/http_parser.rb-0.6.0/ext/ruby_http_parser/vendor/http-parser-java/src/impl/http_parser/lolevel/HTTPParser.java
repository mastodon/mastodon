package http_parser.lolevel;

import java.nio.ByteBuffer;
import http_parser.HTTPException;
import http_parser.HTTPMethod;
import http_parser.HTTPParserUrl;
import http_parser.ParserType;
import static http_parser.lolevel.HTTPParser.C.*;
import static http_parser.lolevel.HTTPParser.State.*;

public class  HTTPParser {
	/* lots of unsigned chars here, not sure what
	   to about them, `bytes` in java suck...  */

	ParserType type;
	State state;
	HState header_state;
  boolean strict;

	int index;
	int flags; // TODO

	int nread;
	long content_length;

  int p_start; // updated each call to execute to indicate where the buffer was before we began calling it.

  /** READ-ONLY **/
  public int http_major;
  public int http_minor;
  public int status_code;   /* responses only */
  public HTTPMethod method; /* requests only */

  /* true  = Upgrade header was present and the parser has exited because of that.
   * false = No upgrade header present.
   * Should be checked when http_parser_execute() returns in addition to
   * error checking.
   */
  public boolean upgrade;

  /** PUBLIC **/
	// TODO : this is used in c to maintain application state.
	// is this even necessary? we have state in java ?
	// consider
  // Object data; /* A pointer to get hook to the "connection" or "socket" object */


  /*
   * technically we could combine all of these (except for url_mark) into one
   * variable, saving stack space, but it seems more clear to have them
   * separated.
   */
  int header_field_mark = -1;
  int header_value_mark = -1;
  int url_mark = -1;
  int body_mark = -1;

  /**
   * Construct a Parser for ParserType.HTTP_BOTH, meaning it
   * determines whether it's parsing a request or a response.
   */
	public HTTPParser() {
		this(ParserType.HTTP_BOTH);
	}

  /**
   * Construct a Parser and initialise it to parse either
   * requests or responses.
   */
	public HTTPParser(ParserType type) {
		this.type  = type;
		switch(type) {
			case HTTP_REQUEST:
				this.state = State.start_req;
				break;
			case HTTP_RESPONSE:
				this.state = State.start_res;
				break;
			case HTTP_BOTH:
				this.state = State.start_req_or_res;
				break;
			default:
				throw new HTTPException("can't happen, invalid ParserType enum");
		}
	}

  /*
   * Utility to facilitate System.out.println style debugging (the way god intended)
   */
	static void p(Object o) {System.out.println(o);}

  /** Comment from C version follows
   *
   * Our URL parser.
   *
   * This is designed to be shared by http_parser_execute() for URL validation,
   * hence it has a state transition + byte-for-byte interface. In addition, it
   * is meant to be embedded in http_parser_parse_url(), which does the dirty
   * work of turning state transitions URL components for its API.
   *
   * This function should only be invoked with non-space characters. It is
   * assumed that the caller cares about (and can detect) the transition between
   * URL and non-URL states by looking for these.
   */
  public State parse_url_char(byte ch) {

    int chi = ch & 0xff;            // utility, ch without signedness for table lookups.

    if(SPACE == ch){
      throw new HTTPException("space as url char");
    }

    switch(state) {
      case req_spaces_before_url:
        /* Proxied requests are followed by scheme of an absolute URI (alpha).
        * All methods except CONNECT are followed by '/' or '*'.
        */
        if(SLASH == ch || STAR == ch){
          return req_path;
        }
        if(isAtoZ(ch)){
          return req_schema;
        }
        break;
      case req_schema:
        if(isAtoZ(ch)){
          return req_schema;
        }
        if(COLON == ch){
          return req_schema_slash;
        }
        break;
      case req_schema_slash:
        if(SLASH == ch){
          return req_schema_slash_slash;
        }
        break;
      case req_schema_slash_slash:
        if(SLASH == ch){
          return req_host_start;
        }
        break;
      case req_host_start:
        if (ch == (byte)'[') {
          return req_host_v6_start;
        }
        if (isHostChar(ch)) {
          return req_host;
        }
        break;

      case req_host:
        if (isHostChar(ch)) {
          return req_host;
        }

      /* FALLTHROUGH */
      case req_host_v6_end:
        switch (ch) {
          case ':':
            return req_port_start;
          case '/':
            return req_path;
          case '?':
            return req_query_string_start;
        }
        break;

      case req_host_v6:
        if (ch == ']') {
          return req_host_v6_end;
        }

      /* FALLTHROUGH */
      case req_host_v6_start:
        if (isHex(ch) || ch == ':') {
          return req_host_v6;
        }
        break;

      case req_port:
        switch (ch) {
          case '/':
            return req_path;
          case '?':
            return req_query_string_start;
        }

      /* FALLTHROUGH */
      case req_port_start:
        if (isDigit(ch)) {
          return req_port;
        }
        break;

      case req_path:
        if (isNormalUrlChar(chi)) {
          return req_path;
        }
        switch (ch) {
          case '?':
            return req_query_string_start;
          case '#':
            return req_fragment_start;
        }

        break;

      case req_query_string_start:
      case req_query_string:
        if (isNormalUrlChar(chi)) {
          return req_query_string;
        }

        switch (ch) {
          case '?':
            /* allow extra '?' in query string */
            return req_query_string;

          case '#':
            return req_fragment_start;
        }

        break;

      case req_fragment_start:
        if (isNormalUrlChar(chi)) {
          return req_fragment;
        }
        switch (ch) {
          case '?':
            return req_fragment;

          case '#':
            return req_fragment_start;
        }
        break;

      case req_fragment:
        if (isNormalUrlChar(ch)) {
          return req_fragment;
        }

        switch (ch) {
          case '?':
          case '#':
            return req_fragment;
        }

        break;
      default:
        break;
    }

    /* We should never fall out of the switch above unless there's an error */
    return dead;
  }

  /** Execute the parser with the currently available data contained in
   * the buffer. The buffers position() and limit() need to be set
   * correctly (obviously) and a will be updated approriately when the
   * method returns to reflect the consumed data.
   */
  public int execute(ParserSettings settings, ByteBuffer data) {

    int p     = data.position();
    this.p_start = p; // this is used for pretty printing errors.
                      // and returning the amount of processed bytes.


    // In case the headers don't provide information about the content
    // length, `execute` needs to be called with an empty buffer to
    // indicate that all the data has been send be the client/server,
    // else there is no way of knowing the message is complete.
    int len = (data.limit() - data.position());
    if (0 == len) {
//      			if (State.body_identity_eof == state) {
//      				settings.call_on_message_complete(this);
//      			}
      switch (state) {
        case body_identity_eof:
          settings.call_on_message_complete(this);
          return data.position() - this.p_start;

        case dead:
        case start_req_or_res:
        case start_res:
        case start_req:
          return data.position() - this.p_start;

        default:
          // should we really consider this an error!?
          throw new HTTPException("empty bytes! "+state); // error
      }
    }


    // in case the _previous_ call to the parser only has data to get to
    // the middle of certain fields, we need to update marks to point at
    // the beginning of the current buffer.
    switch (state) {
      case header_field:
        header_field_mark = p;
        break;
      case header_value:
        header_value_mark = p;
        break;
      case req_path:
      case req_schema:
      case req_schema_slash:
      case req_schema_slash_slash:
      case req_host_start:
      case req_host_v6_start:
      case req_host_v6:
      case req_host_v6_end:
      case req_host:
      case req_port_start:
      case req_port:
      case req_query_string_start:
      case req_query_string:
      case req_fragment_start:
      case req_fragment:
        url_mark = p;
        break;
    }
    boolean reexecute = false;
    int pe = 0;
    byte ch = 0;
    int chi = 0;
    byte c = -1;
    int to_read = 0;

    // this is where the work gets done, traverse the available data...
    while (data.position() != data.limit() || reexecute) {
//      p(state + ": r: " + reexecute + " :: " +p );

      if(!reexecute){
        p = data.position();
        pe = data.limit();
        ch     = data.get();           // the current character to process.
        chi = ch & 0xff;            // utility, ch without signedness for table lookups.
        c      = -1;                   // utility variably used for up- and downcasing etc.
        to_read =  0;                   // used to keep track of how much of body, etc. is left to read

        if (parsing_header(state)) {
          ++nread;
          if (nread > HTTP_MAX_HEADER_SIZE) {
            return error(settings, "possible buffer overflow", data);
          }
        }
      }
      reexecute = false;
//      p(state + " ::: " + ch + " : "  + (((CR == ch) || (LF == ch)) ? ch : ("'" + (char)ch + "'")) +": "+p );

      switch (state) {
         /*
          * this state is used after a 'Connection: close' message
          * the parser will error out if it reads another message
          */
        case dead:
          if (CR == ch || LF == ch){
            break;
          }
          return error(settings, "Connection already closed", data);



        case start_req_or_res:
          if (CR == ch || LF == ch){
            break;
          }
          flags = 0;
          content_length = -1;

          if (H == ch) {
            state = State.res_or_resp_H;
          } else {
            type   = ParserType.HTTP_REQUEST;
            method = start_req_method_assign(ch);
            if (null == method) {
              return error(settings, "invalid method", data);
            }
            index  = 1;
            state  = State.req_method;
          }
          settings.call_on_message_begin(this);
          break;



        case res_or_resp_H:
          if (T == ch) {
            type  = ParserType.HTTP_RESPONSE;
            state = State.res_HT;
          } else {
            if (E != ch) {
              return error(settings, "not E", data);
            }
            type   = ParserType.HTTP_REQUEST;
            method = HTTPMethod.HTTP_HEAD;
            index  = 2;
            state  = State.req_method;
          }
          break;



        case start_res:
          flags = 0;
          content_length = -1;

          switch(ch) {
            case H:
              state = State.res_H;
              break;
            case CR:
            case LF:
              break;
            default:
              return error(settings, "Not H or CR/LF", data);
          }

          settings.call_on_message_begin(this);
          break;



        case res_H:
          if (strict && T != ch) {
            return error(settings, "Not T", data);
          }
          state = State.res_HT;
          break;
        case res_HT:
          if (strict && T != ch) {
return error(settings, "Not T2", data);
          }
          state = State.res_HTT;
          break;
        case res_HTT:
          if (strict && P != ch) {
return error(settings, "Not P", data);
          }
          state = State.res_HTTP;
          break;
        case res_HTTP:
          if (strict && SLASH != ch) {
return error(settings, "Not '/'", data);
          }
          state = State.res_first_http_major;
          break;



        case res_first_http_major:
          if (!isDigit(ch)) {
return error(settings, "Not a digit", data);
          }
          http_major = (int) ch - 0x30;
          state = State.res_http_major;
          break;

        /* major HTTP version or dot */
        case res_http_major:
          if (DOT == ch) {
            state = State.res_first_http_minor;
            break;
          }
          if (!isDigit(ch)) {
return error(settings, "Not a digit", data);
          }
          http_major *= 10;
          http_major += (ch - 0x30);

          if (http_major > 999) {
return error(settings, "invalid http major version: ", data);
          }
          break;

        /* first digit of minor HTTP version */
        case res_first_http_minor:
          if (!isDigit(ch)) {
return error(settings, "Not a digit", data);
          }
          http_minor = (int)ch - 0x30;
          state = State.res_http_minor;
          break;

        /* minor HTTP version or end of request line */
        case res_http_minor:
          if (SPACE == ch) {
            state = State.res_first_status_code;
            break;
          }
          if (!isDigit(ch)) {
return error(settings, "Not a digit", data);
          }
          http_minor *= 10;
          http_minor += (ch - 0x30);
          if (http_minor > 999) {
return error(settings, "invalid http minor version: ", data);
          }
          break;



        case res_first_status_code:
          if (!isDigit(ch)) {
            if (SPACE == ch) {
              break;
            }
return error(settings, "Not a digit (status code)", data);
          }
          status_code = (int)ch - 0x30;
          state = State.res_status_code;
          break;

        case res_status_code:
          if (!isDigit(ch)) {
            switch(ch) {
              case SPACE:
                state = State.res_status;
                break;
              case CR:
                state = State.res_line_almost_done;
                break;
              case LF:
                state = State.header_field_start;
                break;
              default:
return error(settings, "not a valid status code", data);
            }
            break;
          }
          status_code *= 10;
          status_code += (int)ch - 0x30;
          if (status_code > 999) {
return error(settings, "ridiculous status code:", data);
          }

          if (status_code > 99) {
            settings.call_on_status_complete(this);
          }
          break;

        case res_status:
          /* the human readable status. e.g. "NOT FOUND"
           * we are not humans so just ignore this
           * we are not men, we are devo. */

           if (CR == ch) {
            state = State.res_line_almost_done;
            break;
           }
           if (LF == ch) {
            state = State.header_field_start;
            break;
           }
           break;

        case res_line_almost_done:
          if (strict && LF != ch) {
return error(settings, "not LF", data);
          }
          state = State.header_field_start;
          break;



        case start_req:
          if (CR==ch || LF == ch) {
            break;
          }
          flags = 0;
          content_length = -1;

          if(!isAtoZ(ch)){
            return error(settings, "invalid method", data);
          }

          method = start_req_method_assign(ch);
          if (null == method) {
            return error(settings, "invalid method", data);
          }
          index  = 1;
          state  = State.req_method;

          settings.call_on_message_begin(this);
          break;



        case req_method:
          if (0 == ch) {
            return error(settings, "NULL in method", data);
          }

          byte [] arr = method.bytes;

          if (SPACE == ch && index == arr.length) {
            state = State.req_spaces_before_url;
          } else if (arr[index] == ch) {
            // wuhu!
          } else if (HTTPMethod.HTTP_CONNECT == method) {
              if (1 == index && H == ch) {
                method = HTTPMethod.HTTP_CHECKOUT;
              } else if (2 == index && P == ch) {
                method = HTTPMethod.HTTP_COPY;
              }
          } else if (HTTPMethod.HTTP_MKCOL == method) {
              if        (1 == index && O == ch) {
                method = HTTPMethod.HTTP_MOVE;
              } else if (1 == index && E == ch) {
                method = HTTPMethod.HTTP_MERGE;
              } else if (1 == index && DASH == ch) { /* M-SEARCH */
                method = HTTPMethod.HTTP_MSEARCH;
              } else if (2 == index && A == ch) {
                method = HTTPMethod.HTTP_MKACTIVITY;
              }
          } else if (1 == index && HTTPMethod.HTTP_POST     == method) {
            if(R == ch) {
              method = HTTPMethod.HTTP_PROPFIND; /* or HTTP_PROPPATCH */
            }else if(U == ch){
              method = HTTPMethod.HTTP_PUT; /* or HTTP_PURGE */
            }else if(A == ch){
              method = HTTPMethod.HTTP_PATCH;
            }
          } else if (2 == index) {
            if(HTTPMethod.HTTP_PUT == method) {
              if(R == ch){
                method = HTTPMethod.HTTP_PURGE; 
              }
            }else if(HTTPMethod.HTTP_UNLOCK == method){
              if(S == ch){
                method = HTTPMethod.HTTP_UNSUBSCRIBE;
              }
            }
          }else if(4 == index && HTTPMethod.HTTP_PROPFIND == method && P == ch){
            method = HTTPMethod.HTTP_PROPPATCH;
          } else {
            return error(settings, "Invalid HTTP method", data);
          }

          ++index;
          break;



        /******************* URL *******************/
        case req_spaces_before_url:
          if (SPACE == ch) {
            break;
          }
          url_mark  = p;
          if(HTTPMethod.HTTP_CONNECT == method){
            state = req_host_start;
          }

          state = parse_url_char(ch);
          if(state == dead){
            return error(settings, "Invalid something", data);
          }
          break;


        case req_schema:
        case req_schema_slash:
        case req_schema_slash_slash:
        case req_host_start:
        case req_host_v6_start:
        case req_host_v6:
        case req_port_start:
          switch (ch) {
            /* No whitespace allowed here */
            case SPACE:
            case CR:
            case LF:
              return error(settings, "unexpected char in path", data);
            default:
              state = parse_url_char(ch);
              if(dead == state){
                return error(settings, "unexpected char in path", data);
              }
          }
          break;

        case req_host:
        case req_host_v6_end:
        case req_port:
        case req_path:
        case req_query_string_start:
        case req_query_string:
        case req_fragment_start:
        case req_fragment:
          switch (ch) {
            case SPACE:
              settings.call_on_url(this, data, url_mark, p-url_mark);
              settings.call_on_path(this, data, url_mark, p - url_mark);
              url_mark = -1;
              state = State.req_http_start;
              break;
            case CR:
            case LF:
              http_major = 0;
              http_minor = 9;
              state = (CR == ch) ? req_line_almost_done : header_field_start;
              settings.call_on_url(this, data, url_mark, p-url_mark); //TODO check params!!!
              settings.call_on_path(this, data, url_mark, p-url_mark);
              url_mark = -1;
              break;
            default:
              state = parse_url_char(ch);
              if(dead == state){
                return error(settings, "unexpected char in path", data);
              }
          }
          break;
        /******************* URL *******************/



        /******************* HTTP 1.1 *******************/
        case req_http_start:
          switch (ch) {
            case H:
              state = State.req_http_H;
              break;
            case SPACE:
              break;
            default:
              return error(settings, "error in req_http_H", data);
          }
          break;

        case req_http_H:
          if (strict && T != ch) {
            return error(settings, "unexpected char", data);
          }
          state = State.req_http_HT;
          break;

        case req_http_HT:
          if (strict && T != ch) {
            return error(settings, "unexpected char", data);
          }
          state = State.req_http_HTT;
          break;

        case req_http_HTT:
          if (strict && P != ch) {
            return error(settings, "unexpected char", data);
          }
          state = State.req_http_HTTP;
          break;

        case req_http_HTTP:
          if (strict && SLASH != ch) {
            return error(settings, "unexpected char", data);
          }
          state = req_first_http_major;
          break;

        /* first digit of major HTTP version */
        case req_first_http_major:
          if (!isDigit(ch)) {
return error(settings, "non digit in http major", data);
          }
          http_major = (int)ch - 0x30;
          state = State.req_http_major;
          break;

        /* major HTTP version or dot */
        case req_http_major:
          if (DOT == ch) {
            state = State.req_first_http_minor;
            break;
          }

          if (!isDigit(ch)) {
return error(settings, "non digit in http major", data);
          }

          http_major *= 10;
          http_major += (int)ch - 0x30;

          if (http_major > 999) {
return error(settings, "ridiculous http major", data);
          };
          break;

        /* first digit of minor HTTP version */
        case req_first_http_minor:
          if (!isDigit(ch)) {
return error(settings, "non digit in http minor", data);
          }
          http_minor = (int)ch - 0x30;
          state = State.req_http_minor;
          break;

        case req_http_minor:
          if (ch == CR) {
            state = State.req_line_almost_done;
            break;
          }

          if (ch == LF) {
            state = State.header_field_start;
            break;
          }

          /* XXX allow spaces after digit? */

          if (!isDigit(ch)) {
return error(settings, "non digit in http minor", data);
          }

          http_minor *= 10;
          http_minor += (int)ch - 0x30;


          if (http_minor > 999) {
return error(settings, "ridiculous http minor", data);
          };

          break;

        /* end of request line */
        case req_line_almost_done:
        {
          if (ch != LF) {
return error(settings, "missing LF after request line", data);
          }
          state = header_field_start;
          break;
        }

        /******************* HTTP 1.1 *******************/



        /******************* Header *******************/
        case header_field_start:
        {
          if (ch == CR) {
            state = headers_almost_done;
            break;
          }

          if (ch == LF) {
            /* they might be just sending \n instead of \r\n so this would be
             * the second \n to denote the end of headers*/
            state = State.headers_almost_done;
            reexecute = true;
            break;
          }

          c = token(ch);

          if (0 == c) {
            return error(settings, "invalid char in header:", data);
          }

          header_field_mark = p;

          index = 0;
          state = State.header_field;

          switch (c) {
            case C:
              header_state = HState.C;
              break;

            case P:
              header_state = HState.matching_proxy_connection;
              break;

            case T:
              header_state = HState.matching_transfer_encoding;
              break;

            case U:
              header_state = HState.matching_upgrade;
              break;

            default:
              header_state = HState.general;
              break;
          }
          break;
        }



        case header_field:
        {
          c = token(ch);
          if (0 != c) {
            switch (header_state) {
              case general:
                break;

              case C:
                index++;
                header_state = (O == c ? HState.CO : HState.general);
                break;

              case CO:
                index++;
                header_state = (N == c ? HState.CON : HState.general);
                break;

              case CON:
                index++;
                switch (c) {
                  case N:
                    header_state = HState.matching_connection;
                    break;
                  case T:
                    header_state = HState.matching_content_length;
                    break;
                  default:
                    header_state = HState.general;
                    break;
                }
                break;

              /* connection */

              case matching_connection:
                index++;
                if (index > CONNECTION.length || c != CONNECTION[index]) {
                  header_state = HState.general;
                } else if (index == CONNECTION.length-1) {
                  header_state = HState.connection;
                }
                break;

              /* proxy-connection */

              case matching_proxy_connection:
                index++;
                if (index > PROXY_CONNECTION.length || c != PROXY_CONNECTION[index]) {
                  header_state = HState.general;
                } else if (index == PROXY_CONNECTION.length-1) {
                  header_state = HState.connection;
                }
                break;

              /* content-length */

              case matching_content_length:
                index++;
                if (index > CONTENT_LENGTH.length || c != CONTENT_LENGTH[index]) {
                  header_state = HState.general;
                } else if (index == CONTENT_LENGTH.length-1) {
                  header_state = HState.content_length;
                }
                break;

              /* transfer-encoding */

              case matching_transfer_encoding:
                index++;
                if (index > TRANSFER_ENCODING.length || c != TRANSFER_ENCODING[index]) {
                  header_state = HState.general;
                } else if (index == TRANSFER_ENCODING.length-1) {
                  header_state = HState.transfer_encoding;
                }
                break;

              /* upgrade */

              case matching_upgrade:
                index++;
                if (index > UPGRADE.length || c != UPGRADE[index]) {
                  header_state = HState.general;
                } else if (index == UPGRADE.length-1) {
                  header_state = HState.upgrade;
                }
                break;

              case connection:
              case content_length:
              case transfer_encoding:
              case upgrade:
                if (SPACE != ch) header_state = HState.general;
                break;

              default:
return error(settings, "Unknown Header State", data);
            } // switch: header_state
            break;
          } // 0 != c

          if (COLON == ch)  {
            settings.call_on_header_field(this, data, header_field_mark, p-header_field_mark);
            header_field_mark = -1;

            state = State.header_value_start;
            break;
          }

          if (CR == ch) {
            state = State.header_almost_done;
            settings.call_on_header_field(this, data, header_field_mark, p-header_field_mark);

            header_field_mark = -1;
            break;
          }

          if (ch == LF) {
            settings.call_on_header_field(this, data, header_field_mark, p-header_field_mark);
            header_field_mark = -1;

            state = State.header_field_start;
            break;
          }

return error(settings, "invalid header field", data);
        }



        case header_value_start:
        {
          if ((SPACE == ch) || (TAB  == ch)) break;

          header_value_mark = p;

          state = State.header_value;
          index = 0;


          if (CR == ch) {
            settings.call_on_header_value(this, data, header_value_mark, p-header_value_mark);
            header_value_mark = -1;

            header_state = HState.general;
            state = State.header_almost_done;
            break;
          }

          if (LF == ch) {
            settings.call_on_header_value(this, data, header_value_mark, p-header_value_mark);
            header_value_mark = -1;

            state = State.header_field_start;
            break;
          }


          c = upper(ch);

          switch (header_state) {
            case upgrade:
              flags |= F_UPGRADE;
              header_state = HState.general;
              break;

            case transfer_encoding:
              /* looking for 'Transfer-Encoding: chunked' */
              if (C == c) {
                header_state = HState.matching_transfer_encoding_chunked;
              } else {
                header_state = HState.general;
              }
              break;

            case content_length:
              if (!isDigit(ch)) {
return error(settings, "Content-Length not numeric", data);
              }
              content_length = (int)ch - 0x30;
              break;

            case connection:
              /* looking for 'Connection: keep-alive' */
              if (K == c) {
                header_state = HState.matching_connection_keep_alive;
              /* looking for 'Connection: close' */
              } else if (C == c) {
                header_state = HState.matching_connection_close;
              } else {
                header_state = HState.general;
              }
              break;

            default:
              header_state = HState.general;
              break;
          }
          break;
        } // header value start



        case header_value:
        {

          if (CR == ch) {
            settings.call_on_header_value(this, data, header_value_mark, p-header_value_mark);
            header_value_mark = -1;

            state = State.header_almost_done;
            break;
          }

          if (LF == ch) {
            settings.call_on_header_value(this, data, header_value_mark, p-header_value_mark);
            header_value_mark = -1;
            state = header_almost_done;
            reexecute = true;
            break;
          }

          c = upper(ch);
          switch (header_state) {
            case general:
              break;

            case connection:
            case transfer_encoding:
return error(settings, "Shouldn't be here", data);

            case content_length:
              if (SPACE == ch) {
                break;
              }
              if (!isDigit(ch)) {
return error(settings, "Content-Length not numeric", data);
              }

              long t = content_length; 
              t *= 10;
              t += (long)ch - 0x30;

              /* Overflow? */
              // t will wrap and become negative ...
              if (t < content_length) { 
                return error(settings, "Invalid content length", data);
              }
              content_length = t;
              break;

            /* Transfer-Encoding: chunked */
            case matching_transfer_encoding_chunked:
              index++;
              if (index > CHUNKED.length || c != CHUNKED[index]) {
                header_state = HState.general;
              } else if (index == CHUNKED.length-1) {
                header_state = HState.transfer_encoding_chunked;
              }
              break;

            /* looking for 'Connection: keep-alive' */
            case matching_connection_keep_alive:
              index++;
              if (index > KEEP_ALIVE.length || c != KEEP_ALIVE[index]) {
                header_state = HState.general;
              } else if (index == KEEP_ALIVE.length-1) {
                header_state = HState.connection_keep_alive;
              }
              break;

            /* looking for 'Connection: close' */
            case matching_connection_close:
              index++;
              if (index > CLOSE.length || c != CLOSE[index]) {
                header_state = HState.general;
              } else if (index == CLOSE.length-1) {
                header_state = HState.connection_close;
              }
              break;

            case transfer_encoding_chunked:
            case connection_keep_alive:
            case connection_close:
              if (SPACE != ch) header_state = HState.general;
              break;

            default:
              state = State.header_value;
              header_state = HState.general;
              break;
          }
          break;
        } // header_value



        case header_almost_done:
          if (!header_almost_done(ch)) {
            return error(settings, "incorrect header ending, expecting LF", data);
          }
          break;

        case header_value_lws:
          if (SPACE == ch || TAB == ch ){
            state = header_value_start;
          } else {
            state = header_field_start;
            reexecute = true;
          }
          break;

        case headers_almost_done:
          if (LF != ch) {
            return error(settings, "header not properly completed", data);
          }
          if (0 != (flags & F_TRAILING)) {
            /* End of a chunked request */
            state = new_message();
            settings.call_on_headers_complete(this);
            settings.call_on_message_complete(this);
            break;
          }

          state = headers_done;

          if (0 != (flags & F_UPGRADE) || HTTPMethod.HTTP_CONNECT == method) {
            upgrade = true;
          }

          /* Here we call the headers_complete callback. This is somewhat
          * different than other callbacks because if the user returns 1, we
          * will interpret that as saying that this message has no body. This
          * is needed for the annoying case of recieving a response to a HEAD
          * request.
          */

          /* (responses to HEAD request contain a CONTENT-LENGTH header
          * but no content)
          *
          * Consider what to do here: I don't like the idea of the callback
          * interface having a different contract in the case of HEAD
          * responses. The alternatives would be either to:
          *
          * a.) require the header_complete callback to implement a different
          * interface or
          *
          * b.) provide an overridden execute(bla, bla, boolean
          * parsingHeader) implementation ...
          */

          /*TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO */
          if (null != settings.on_headers_complete) {
            settings.call_on_headers_complete(this);
            //return;
          }

          //        if (null != settings.on_headers_complete) {
          //          switch (settings.on_headers_complete.cb(parser)) {
          //            case 0:
          //              break;
          //
          //            case 1:
          //              flags |= F_SKIPBODY;
          //              break;
          //
          //            default:
          //              return p - data; /* Error */ // TODO // RuntimeException ?
          //          }
          //        }
          reexecute = true;
          break;

        case headers_done:
          if (strict && (LF != ch)) {
            return error(settings, "STRICT CHECK", data); //TODO correct error msg
          }

          nread = 0;

          // Exit, the rest of the connect is in a different protocol.
          if (upgrade) {
            state = new_message();
            settings.call_on_message_complete(this);
            return data.position()-this.p_start;
          }

          if (0 != (flags & F_SKIPBODY)) {
            state = new_message();
            settings.call_on_message_complete(this);
          } else if (0 != (flags & F_CHUNKED)) {
            /* chunked encoding - ignore Content-Length header */
            state = State.chunk_size_start;
          } else {
            if (content_length == 0) {
              /* Content-Length header given but zero: Content-Length: 0\r\n */
              state = new_message();
              settings.call_on_message_complete(this);
            } else if (content_length != -1) {
              /* Content-Length header given and non-zero */
              state = State.body_identity;
            } else {
              if (type == ParserType.HTTP_REQUEST || !http_message_needs_eof()) {
                /* Assume content-length 0 - read the next */
                state = new_message();
                settings.call_on_message_complete(this);
              } else {
                /* Read body until EOF */
                state = State.body_identity_eof;
              }
            }
          }

          break;
        /******************* Header *******************/




        /******************* Body *******************/
        case body_identity:
          to_read = min(pe - p, content_length); //TODO change to use buffer?
          body_mark = p;

          if (to_read > 0) {
            settings.call_on_body(this, data, p, to_read);
            data.position(p+to_read);
            content_length -= to_read;

            if (content_length == 0) {
              state = message_done;
              reexecute = true;
            }
          }
          break;



        case body_identity_eof:
          to_read = pe - p;  // TODO change to use buffer ?
          if (to_read > 0) {
            settings.call_on_body(this, data, p, to_read);
            data.position(p+to_read);
          }
          break;
        
        case message_done:
          state = new_message();
          settings.call_on_message_complete(this);
          break;
        /******************* Body *******************/



        /******************* Chunk *******************/
        case chunk_size_start:
          if (1 != this.nread) {
return error(settings, "nread != 1 (chunking)", data);

          }
          if (0 == (flags & F_CHUNKED)) {
return error(settings, "not chunked", data);
          }

          c = UNHEX[chi];
          if (c == -1) {
return error(settings, "invalid hex char in chunk content length", data);
          }
          content_length = c;
          state = State.chunk_size;
          break;



        case chunk_size:
          if (0 == (flags & F_CHUNKED)) {
            return error(settings, "not chunked", data);
          }

          if (CR == ch) {
            state = State.chunk_size_almost_done;
            break;
          }

          c = UNHEX[chi];

          if (c == -1) {
            if (SEMI == ch || SPACE == ch) {
              state = State.chunk_parameters;
              break;
            }
            return error(settings, "invalid hex char in chunk content length", data);
          }
          long t = content_length;
          
          t *= 16;
          t += c;
          if(t < content_length){
            return error(settings, "invalid content length", data);
          }
          content_length = t;
          break;



        case chunk_parameters:
          if (0 == (flags & F_CHUNKED)) {
return error(settings, "not chunked", data);
          }
          /* just ignore this shit. TODO check for overflow */
          if (CR == ch) {
            state = State.chunk_size_almost_done;
            break;
          }
          break;



        case chunk_size_almost_done:
          if (0 == (flags & F_CHUNKED)) {
return error(settings, "not chunked", data);
          }
          if (strict && LF != ch) {
return error(settings, "expected LF at end of chunk size", data);
          }

          this.nread = 0;

          if (0 == content_length) {
            flags |= F_TRAILING;
            state = State.header_field_start;
          } else {
            state = State.chunk_data;
          }
          break;



        case chunk_data:
          //TODO Apply changes from C version for s_chunk_data
          if (0 == (flags & F_CHUNKED)) {
            return error(settings, "not chunked", data);
          }

          to_read = min(pe-p, content_length);
          if (to_read > 0) {
            settings.call_on_body(this, data, p, to_read);
            data.position(p+to_read);
          }

          if (to_read == content_length) {
            state = State.chunk_data_almost_done;
          }

          content_length -= to_read;
          break;



        case chunk_data_almost_done:
          if (0 == (flags & F_CHUNKED)) {
return error(settings, "not chunked", data);
          }
          if (strict && CR != ch) {
return error(settings, "chunk data terminated incorrectly, expected CR", data);
          }
          state = State.chunk_data_done;
          //TODO CALLBACK_DATA(body)
          // settings.call_on_body(this, data,p,?);
          break;



        case chunk_data_done:
          if (0 == (flags & F_CHUNKED)) {
return error(settings, "not chunked", data);
          }
          if (strict && LF != ch) {
return error(settings, "chunk data terminated incorrectly, expected LF", data);
          }
          state = State.chunk_size_start;
          break;
        /******************* Chunk *******************/



        default:
return error(settings, "unhandled state", data);

      } // switch
    } // while

    p = data.position();


    /* Reaching this point assumes that we only received part of a
     * message, inform the callbacks about the progress made so far*/

	  settings.call_on_header_field(this, data, header_field_mark, p-header_field_mark);
    settings.call_on_header_value(this, data, header_value_mark, p-header_value_mark);
    settings.call_on_url         (this, data, url_mark,          p-url_mark);
    settings.call_on_path        (this, data, url_mark,          p-url_mark);
    
    return data.position()-this.p_start;
  } // execute

  int error (ParserSettings settings, String mes, ByteBuffer data) {
    settings.call_on_error(this, mes, data, this.p_start);
    this.state = State.dead;
    return data.position()-this.p_start;
  }

  public boolean http_message_needs_eof() {
    if(type == ParserType.HTTP_REQUEST){
      return false;
    }
    /* See RFC 2616 section 4.4 */
    if ((status_code / 100 == 1) || /* 1xx e.g. Continue */
        (status_code == 204) ||     /* No Content */
        (status_code == 304) ||     /* Not Modified */
        (flags & F_SKIPBODY) != 0) {     /* response to a HEAD request */
          return false;
      }
    if ((flags & F_CHUNKED) != 0 || content_length != -1) {
      return false;
    }

    return true;
  }

  /* If http_should_keep_alive() in the on_headers_complete or
   * on_message_complete callback returns true, then this will be should be
   * the last message on the connection.
   * If you are the server, respond with the "Connection: close" header.
   * If you are the client, close the connection.
   */
  public boolean http_should_keep_alive() {
    if (http_major > 0 && http_minor > 0) {
      /* HTTP/1.1 */
      if ( 0 != (flags & F_CONNECTION_CLOSE) ) {
        return false;
      }
    } else {
      /* HTTP/1.0 or earlier */
      if ( 0 == (flags & F_CONNECTION_KEEP_ALIVE) ) {
        return false;
      }
    }
    return !http_message_needs_eof();
  }

  public int parse_url(ByteBuffer data, boolean is_connect, HTTPParserUrl u) {
    
    UrlFields uf = UrlFields.UF_MAX;
    UrlFields old_uf = UrlFields.UF_MAX;
    u.port = 0;
    u.field_set = 0;
    state = (is_connect ? State.req_host_start : State.req_spaces_before_url);
    int p_init = data.position();
    int p = 0;
    byte ch = 0;
    while (data.position() != data.limit()) {
      p = data.position();
      ch = data.get();
      state = parse_url_char(ch);
      switch(state) {
        case dead:
          return 1;

        /* Skip delimeters */
        case req_schema_slash:
        case req_schema_slash_slash:
        case req_host_start:
        case req_host_v6_start:
        case req_host_v6_end:
        case req_port_start:
        case req_query_string_start:
        case req_fragment_start:
          continue;

        case req_schema:
          uf = UrlFields.UF_SCHEMA;
          break;

        case req_host:
        case req_host_v6:
          uf = UrlFields.UF_HOST;
          break;

        case req_port:
          uf = UrlFields.UF_PORT;
          break;

        case req_path:
          uf = UrlFields.UF_PATH;
          break;

        case req_query_string:
          uf = UrlFields.UF_QUERY;
          break;

        case req_fragment:
          uf = UrlFields.UF_FRAGMENT;
          break;

        default:
          return 1;
      }
      /* Nothing's changed; soldier on */
      if (uf == old_uf) {
        u.field_data[uf.getIndex()].len++;
        continue;
      }

      u.field_data[uf.getIndex()].off = p - p_init;
      u.field_data[uf.getIndex()].len = 1;

      u.field_set |= (1 << uf.getIndex());
      old_uf = uf;

    }

    /* CONNECT requests can only contain "hostname:port" */
    if (is_connect && u.field_set != ((1 << UrlFields.UF_HOST.getIndex())|(1 << UrlFields.UF_PORT.getIndex()))) {
      return 1;
    }

    /* Make sure we don't end somewhere unexpected */
    switch (state) {
      case req_host_v6_start:
      case req_host_v6:
      case req_host_v6_end:
      case req_host:
      case req_port_start:
        return 1;
      default:
        break;
    }

    if (0 != (u.field_set & (1 << UrlFields.UF_PORT.getIndex()))) {
      /* Don't bother with endp; we've already validated the string */
      int v = strtoi(data, p_init + u.field_data[UrlFields.UF_PORT.getIndex()].off);

      /* Ports have a max value of 2^16 */
      if (v > 0xffff) {
        return 1;
      }

      u.port = v;
    }
    
    return 0;
  }

  //hacky reimplementation of srttoul, tailored for our simple needs
  //we only need to parse port val, so no negative values etc
  int strtoi(ByteBuffer data, int start_pos) {
    data.position(start_pos);
    byte ch;
    String str = "";
    while(data.position() < data.limit()) {
      ch = data.get();
      if(Character.isWhitespace((char)ch)){
        continue;
      }
      if(isDigit(ch)){
        str = str + (char)ch; //TODO replace with something less hacky
      }else{
        break;
      }
    }
    return Integer.parseInt(str);
  }
  
  boolean isDigit(byte b) {
    if (b >= 0x30 && b <=0x39) {
      return true;
    }
    return false;
  }

  boolean isHex(byte b) {
    return isDigit(b) || (lower(b) >= 0x61 /*a*/ && lower(b) <= 0x66 /*f*/);
  }

  boolean isAtoZ(byte b) {
    byte c = lower(b);
    return (c>= 0x61 /*a*/ && c <=  0x7a /*z*/);
  }


  byte lower (byte b) {
    return (byte)(b|0x20);
  }

  byte upper(byte b) {
    char c = (char)(b);
    return (byte)Character.toUpperCase(c);
  }

  byte token(byte b) {
    if(!strict){
        return (b == (byte)' ') ? (byte)' ' : (byte)tokens[b] ;
    }else{
        return (byte)tokens[b];
    }
  }

  boolean isHostChar(byte ch){
    if(!strict){
      return (isAtoZ(ch)) || isDigit(ch) || DOT == ch || DASH == ch || UNDER == ch ;
    }else{
      return (isAtoZ(ch)) || isDigit(ch) || DOT == ch || DASH == ch;
    }
  }

  boolean isNormalUrlChar(int chi) {
    if(!strict){
      return (chi > 0x80) || normal_url_char[chi];
    }else{
      return normal_url_char[chi];
    }
  }

  HTTPMethod start_req_method_assign(byte c){
    switch (c) {
      case C: return HTTPMethod.HTTP_CONNECT;  /* or COPY, CHECKOUT */
      case D: return HTTPMethod.HTTP_DELETE;
      case G: return HTTPMethod.HTTP_GET;
      case H: return HTTPMethod.HTTP_HEAD;
      case L: return HTTPMethod.HTTP_LOCK;
      case M: return HTTPMethod.HTTP_MKCOL;    /* or MOVE, MKACTIVITY, MERGE, M-SEARCH */
      case N: return HTTPMethod.HTTP_NOTIFY;
      case O: return HTTPMethod.HTTP_OPTIONS;
      case P: return HTTPMethod.HTTP_POST;     /* or PROPFIND|PROPPATCH|PUT|PATCH|PURGE */
      case R: return HTTPMethod.HTTP_REPORT;
      case S: return HTTPMethod.HTTP_SUBSCRIBE;
      case T: return HTTPMethod.HTTP_TRACE;
      case U: return HTTPMethod.HTTP_UNLOCK; /* or UNSUBSCRIBE */
    }
    return null; // ugh.
  }

  boolean header_almost_done(byte ch) {
    if (strict && LF != ch) {
      return false;
    }

    state = State.header_value_lws;
    // TODO java enums support some sort of bitflag mechanism !?
    switch (header_state) {
      case connection_keep_alive:
        flags |= F_CONNECTION_KEEP_ALIVE;
        break;
      case connection_close:
        flags |= F_CONNECTION_CLOSE;
        break;
      case transfer_encoding_chunked:
        flags |= F_CHUNKED;
        break;
      default:
        break;
    }
    return true;
  }

//  boolean headers_almost_done (byte ch, ParserSettings settings) {
//  } // headers_almost_done


  final int min (int a, int b) {
    return a < b ? a : b;
  }
  
  final int min (int a, long b) {
    return a < b ? a : (int)b;
  }

  /* probably not the best place to hide this ... */
	public boolean HTTP_PARSER_STRICT;
  State new_message() {
    if (HTTP_PARSER_STRICT){
      return http_should_keep_alive() ? start_state() : State.dead;
    } else {
      return start_state();
    }

  }

  State start_state() {
    return type == ParserType.HTTP_REQUEST ? State.start_req : State.start_res;
  }


	boolean parsing_header(State state) {

		switch (state) {
			case chunk_data :
			case chunk_data_almost_done :
			case chunk_data_done :
			case body_identity :
			case body_identity_eof :
      case message_done :
				return false;

		}
    return true;
	}

	/* "Dial C for Constants" */
  static class C {
    static final int HTTP_MAX_HEADER_SIZE = 80 * 1024;

    static final int F_CHUNKED               = 1 << 0;
    static final int F_CONNECTION_KEEP_ALIVE = 1 << 1;
    static final int F_CONNECTION_CLOSE      = 1 << 2;
    static final int F_TRAILING              = 1 << 3;
    static final int F_UPGRADE               = 1 << 4;
    static final int F_SKIPBODY              = 1 << 5;

    static final byte [] UPCASE = {
      0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
      0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
      0x20,0x00,0x00,0x00,0x00,0x00,0x00,0x00,  0x00,0x00,0x00,0x00,0x00,0x2d,0x00,0x2f,
      0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,  0x38,0x39,0x00,0x00,0x00,0x00,0x00,0x00,
      0x00,0x41,0x42,0x43,0x44,0x45,0x46,0x47,  0x48,0x49,0x4a,0x4b,0x4c,0x4d,0x4e,0x4f,
      0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,  0x58,0x59,0x5a,0x00,0x00,0x00,0x00,0x5f,
      0x00,0x41,0x42,0x43,0x44,0x45,0x46,0x47,  0x48,0x49,0x4a,0x4b,0x4c,0x4d,0x4e,0x4f,
      0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,  0x58,0x59,0x5a,0x00,0x00,0x00,0x00,0x00,
      0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
      0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
      0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
      0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
      0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
      0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
      0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
      0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    };
    static final byte [] CONNECTION = {
      0x43, 0x4f, 0x4e, 0x4e, 0x45, 0x43, 0x54, 0x49, 0x4f, 0x4e,
    };
    static final byte [] PROXY_CONNECTION = {
      0x50, 0x52, 0x4f, 0x58, 0x59, 0x2d, 0x43, 0x4f, 0x4e, 0x4e, 0x45, 0x43, 0x54, 0x49, 0x4f, 0x4e,
    };
    static final byte [] CONTENT_LENGTH = {
      0x43, 0x4f, 0x4e, 0x54, 0x45, 0x4e, 0x54, 0x2d, 0x4c, 0x45, 0x4e, 0x47, 0x54, 0x48,
    };
    static final byte [] TRANSFER_ENCODING = {
      0x54, 0x52, 0x41, 0x4e, 0x53, 0x46, 0x45, 0x52, 0x2d, 0x45, 0x4e, 0x43, 0x4f, 0x44, 0x49, 0x4e, 0x47,
    };
    static final byte [] UPGRADE = {
      0x55, 0x50, 0x47, 0x52, 0x41, 0x44, 0x45,
    };
    static final byte [] CHUNKED = {
      0x43, 0x48, 0x55, 0x4e, 0x4b, 0x45, 0x44,
    };
    static final byte [] KEEP_ALIVE = {
      0x4b, 0x45, 0x45, 0x50, 0x2d, 0x41, 0x4c, 0x49, 0x56, 0x45,
    };
    static final byte [] CLOSE = {
      0x43, 0x4c, 0x4f, 0x53, 0x45,
    };

    /* Tokens as defined by rfc 2616. Also lowercases them.
     *        token       = 1*<any CHAR except CTLs or separators>
     *     separators     = "(" | ")" | "<" | ">" | "@"
     *                    | "," | ";" | ":" | "\" | <">
     *                    | "/" | "[" | "]" | "?" | "="
     *                    | "{" | "}" | SP | HT
     */

    static final char [] tokens = {
/*   0 nul    1 soh    2 stx    3 etx    4 eot    5 enq    6 ack    7 bel  */
        0,       0,       0,       0,       0,       0,       0,       0,
/*   8 bs     9 ht    10 nl    11 vt    12 np    13 cr    14 so    15 si   */
        0,       0,       0,       0,       0,       0,       0,       0,
/*  16 dle   17 dc1   18 dc2   19 dc3   20 dc4   21 nak   22 syn   23 etb */
        0,       0,       0,       0,       0,       0,       0,       0,
/*  24 can   25 em    26 sub   27 esc   28 fs    29 gs    30 rs    31 us  */
        0,       0,       0,       0,       0,       0,       0,       0,
/*  32 sp    33  !    34  "    35  #    36  $    37  %    38  &    39  '  */
        0,     '!',       0,     '#',     '$',     '%',     '&',    '\'',
/*  40  (    41  )    42  *    43  +    44  ,    45  -    46  .    47  /  */
        0,       0,      '*',     '+',       0,     '-',     '.',     0 ,
/*  48  0    49  1    50  2    51  3    52  4    53  5    54  6    55  7  */
       '0',     '1',     '2',     '3',     '4',     '5',     '6',     '7',
/*  56  8    57  9    58  :    59  ;    60  <    61  =    62  >    63  ?  */
       '8',     '9',      0,       0,       0,       0,       0,       0,
/*  64  @    65  A    66  B    67  C    68  D    69  E    70  F    71  G  */
        0,      'A',     'B',     'C',     'D',     'E',     'F',     'G',
/*  72  H    73  I    74  J    75  K    76  L    77  M    78  N    79  O  */
       'H',     'I',     'J',     'K',     'L',     'M',     'N',     'O',
/*  80  P    81  Q    82  R    83  S    84  T    85  U    86  V    87  W  */
       'P',     'Q',     'R',     'S',     'T',     'U',     'V',     'W',
/*  88  X    89  Y    90  Z    91  [    92  \    93  ]    94  ^    95  _  */
       'X',     'Y',     'Z',      0,       0,       0,       0,      '_',
/*  96  `    97  a    98  b    99  c   100  d   101  e   102  f   103  g  */
        0,      'A',     'B',     'C',     'D',     'E',     'F',     'G',
/* 104  h   105  i   106  j   107  k   108  l   109  m   110  n   111  o  */
       'H',     'I',     'J',     'K',     'L',     'M',     'N',     'O',
/* 112  p   113  q   114  r   115  s   116  t   117  u   118  v   119  w  */
       'P',     'Q',     'R',     'S',     'T',     'U',     'V',     'W',
/* 120  x   121  y   122  z   123  {   124  |   125  }   126  ~   127 del */
       'X',     'Y',     'Z',      0,      '|',      0,      '~',       0,
/* hi bit set, not ascii                                                  */
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0,
        0,       0,       0,       0,       0,       0,       0,       0, };

    static final byte [] UNHEX =
    {    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        ,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        ,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        , 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,-1,-1,-1,-1,-1,-1
        ,-1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1
        ,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        ,-1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1
        ,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        ,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        ,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        ,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        ,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        ,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        ,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        ,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        ,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
    };

    static final boolean [] normal_url_char = {
/*   0 nul    1 soh    2 stx    3 etx    4 eot    5 enq    6 ack    7 bel  */
    false,   false,   false,   false,   false,   false,   false,   false,
/*   8 bs     9 ht    10 nl    11 vt    12 np    13 cr    14 so    15 si   */
    false,   false,   false,   false,   false,   false,   false,   false,
/*  16 dle   17 dc1   18 dc2   19 dc3   20 dc4   21 nak   22 syn   23 etb */
    false,   false,   false,   false,   false,   false,   false,   false,
/*  24 can   25 em    26 sub   27 esc   28 fs    29 gs    30 rs    31 us  */
    false,   false,   false,   false,   false,   false,   false,   false,
/*  32 sp    33  !    34  "    35  #    36  $    37  %    38  &    39  '  */
    false,    true,    true,   false,    true,    true,    true,    true,
/*  40  (    41  )    42  *    43  +    44  ,    45  -    46  .    47  /  */
     true,    true,    true,    true,    true,    true,    true,    true,
/*  48  0    49  1    50  2    51  3    52  4    53  5    54  6    55  7  */
     true,    true,    true,    true,    true,    true,    true,    true,
/*  56  8    57  9    58  :    59  ;    60  <    61  =    62  >    63  ?  */
     true,    true,    true,    true,    true,    true,    true,   false,
/*  64  @    65  A    66  B    67  C    68  D    69  E    70  F    71  G  */
     true,    true,    true,    true,    true,    true,    true,    true,
/*  72  H    73  I    74  J    75  K    76  L    77  M    78  N    79  O  */
     true,    true,    true,    true,    true,    true,    true,    true,
/*  80  P    81  Q    82  R    83  S    84  T    85  U    86  V    87  W  */
     true,    true,    true,    true,    true,    true,    true,    true,
/*  88  X    89  Y    90  Z    91  [    92  \    93  ]    94  ^    95  _  */
     true,    true,    true,    true,    true,    true,    true,    true,
/*  96  `    97  a    98  b    99  c   100  d   101  e   102  f   103  g  */
     true,    true,    true,    true,    true,    true,    true,    true,
/* 104  h   105  i   106  j   107  k   108  l   109  m   110  n   111  o  */
     true,    true,    true,    true,    true,    true,    true,    true,
/* 112  p   113  q   114  r   115  s   116  t   117  u   118  v   119  w  */
     true,    true,    true,    true,    true,    true,    true,    true,
/* 120  x   121  y   122  z   123  {   124  |   125  }   126  ~   127 del */
     true,    true,    true,    true,    true,    true,    true,   false,

/*    hi bit set, not ascii                                                  */
/*    Remainder of non-ASCII range are accepted as-is to support implicitly UTF-8
 *    encoded paths. This is out of spec, but clients generate this and most other
 *    HTTP servers support it. We should, too. */

     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,
     true,    true,    true,    true,    true,    true,    true,    true,

    };

    public static final byte A = 0x41;
    public static final byte B = 0x42;
    public static final byte C = 0x43;
    public static final byte D = 0x44;
    public static final byte E = 0x45;
    public static final byte F = 0x46;
    public static final byte G = 0x47;
    public static final byte H = 0x48;
    public static final byte I = 0x49;
    public static final byte J = 0x4a;
    public static final byte K = 0x4b;
    public static final byte L = 0x4c;
    public static final byte M = 0x4d;
    public static final byte N = 0x4e;
    public static final byte O = 0x4f;
    public static final byte P = 0x50;
    public static final byte Q = 0x51;
    public static final byte R = 0x52;
    public static final byte S = 0x53;
    public static final byte T = 0x54;
    public static final byte U = 0x55;
    public static final byte V = 0x56;
    public static final byte W = 0x57;
    public static final byte X = 0x58;
    public static final byte Y = 0x59;
    public static final byte Z = 0x5a;
    public static final byte UNDER = 0x5f;
    public static final byte CR = 0x0d;
    public static final byte LF = 0x0a;
    public static final byte DOT = 0x2e;
    public static final byte SPACE = 0x20;
    public static final byte TAB = 0x09;
    public static final byte SEMI = 0x3b;
    public static final byte COLON = 0x3a;
    public static final byte HASH = 0x23;
    public static final byte QMARK = 0x3f;
    public static final byte SLASH = 0x2f;
    public static final byte DASH = 0x2d;
    public static final byte STAR = 0x2a;
    public static final byte NULL = 0x00;
  }

  enum State {

    dead

    , start_req_or_res
    , res_or_resp_H
    , start_res
    , res_H
    , res_HT
    , res_HTT
    , res_HTTP
    , res_first_http_major
    , res_http_major
    , res_first_http_minor
    , res_http_minor
    , res_first_status_code
    , res_status_code
    , res_status
    , res_line_almost_done

    , start_req

    , req_method
    , req_spaces_before_url
    , req_schema
    , req_schema_slash
    , req_schema_slash_slash
    , req_host_start
    , req_host_v6_start
    , req_host_v6
    , req_host_v6_end
    , req_host
    , req_port_start
    , req_port
    , req_path
    , req_query_string_start
    , req_query_string
    , req_fragment_start
    , req_fragment
    , req_http_start
    , req_http_H
    , req_http_HT
    , req_http_HTT
    , req_http_HTTP
    , req_first_http_major
    , req_http_major
    , req_first_http_minor
    , req_http_minor
    , req_line_almost_done

    , header_field_start
    , header_field
    , header_value_start
    , header_value
    , header_value_lws

    , header_almost_done

    , chunk_size_start
    , chunk_size
    , chunk_parameters
    , chunk_size_almost_done

    , headers_almost_done
    , headers_done
// This space intentionally not left blank, comment from c, for orientation...
// the c version uses <= s_header_almost_done in java, we list the states explicitly
// in `parsing_header()`
/* Important: 's_headers_done' must be the last 'header' state. All
 * states beyond this must be 'body' states. It is used for overflow
 * checking. See the PARSING_HEADER() macro.
 */
    , chunk_data
    , chunk_data_almost_done
    , chunk_data_done

    , body_identity
    , body_identity_eof
    , message_done

  }
  enum HState {
      general
    , C
    , CO
    , CON

    , matching_connection
    , matching_proxy_connection
    , matching_content_length
    , matching_transfer_encoding
    , matching_upgrade

    , connection
    , content_length
    , transfer_encoding
    , upgrade

    , matching_transfer_encoding_chunked
    , matching_connection_keep_alive
    , matching_connection_close

    , transfer_encoding_chunked
    , connection_keep_alive
    , connection_close
  }
  public enum UrlFields {
      UF_SCHEMA(0)
    , UF_HOST(1)
    , UF_PORT(2)
    , UF_PATH(3)
    , UF_QUERY(4)
    , UF_FRAGMENT(5)
    , UF_MAX(6);


    private final int index;

    private UrlFields(int index) {
      this.index = index;
    }
    public int getIndex() {
      return index;
    }

  }
}
