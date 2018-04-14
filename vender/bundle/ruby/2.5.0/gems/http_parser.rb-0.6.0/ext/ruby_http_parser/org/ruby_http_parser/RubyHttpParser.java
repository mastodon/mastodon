package org.ruby_http_parser;

import http_parser.HTTPException;
import http_parser.HTTPMethod;
import http_parser.HTTPParser;
import http_parser.lolevel.HTTPCallback;
import http_parser.lolevel.HTTPDataCallback;
import http_parser.lolevel.ParserSettings;

import java.nio.ByteBuffer;

import org.jcodings.Encoding;
import org.jcodings.specific.UTF8Encoding;
import org.jruby.Ruby;
import org.jruby.RubyArray;
import org.jruby.RubyClass;
import org.jruby.RubyHash;
import org.jruby.RubyNumeric;
import org.jruby.RubyObject;
import org.jruby.RubyString;
import org.jruby.RubySymbol;
import org.jruby.anno.JRubyMethod;
import org.jruby.exceptions.RaiseException;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.util.ByteList;

public class RubyHttpParser extends RubyObject {

  @JRubyMethod(name = "strict?", module = true)
  public static IRubyObject strict(IRubyObject recv) {
    return recv.getRuntime().newBoolean(true);
  }

  public static ObjectAllocator ALLOCATOR = new ObjectAllocator() {
    public IRubyObject allocate(Ruby runtime, RubyClass klass) {
      return new RubyHttpParser(runtime, klass);
    }
  };

  byte[] fetchBytes(ByteBuffer b, int pos, int len) {
    byte[] by = new byte[len];
    int saved = b.position();
    b.position(pos);
    b.get(by);
    b.position(saved);
    return by;
  }

  public class StopException extends RuntimeException {
  }

  private Ruby runtime;
  private HTTPParser parser;
  private ParserSettings settings;

  private RubyClass eParserError;

  private RubyHash headers;

  private IRubyObject on_message_begin;
  private IRubyObject on_headers_complete;
  private IRubyObject on_body;
  private IRubyObject on_message_complete;

  private IRubyObject requestUrl;
  private IRubyObject requestPath;
  private IRubyObject queryString;
  private IRubyObject fragment;

  private IRubyObject header_value_type;
  private IRubyObject upgradeData;

  private IRubyObject callback_object;

  private boolean completed;

  private byte[] _current_header;
  private byte[] _last_header;

  private static final Encoding UTF8 = UTF8Encoding.INSTANCE;

  public RubyHttpParser(final Ruby runtime, RubyClass clazz) {
    super(runtime, clazz);

    this.runtime = runtime;
    this.eParserError = (RubyClass) runtime.getModule("HTTP").getClass("Parser").getConstant("Error");

    this.on_message_begin = null;
    this.on_headers_complete = null;
    this.on_body = null;
    this.on_message_complete = null;

    this.callback_object = null;

    this.completed = false;

    this.header_value_type = runtime.getModule("HTTP").getClass("Parser")
        .getInstanceVariable("@default_header_value_type");

    initSettings();
    init();
  }

  private void initSettings() {
    this.settings = new ParserSettings();

    this.settings.on_url = new HTTPDataCallback() {
      public int cb(http_parser.lolevel.HTTPParser p, ByteBuffer buf, int pos, int len) {
        byte[] data = fetchBytes(buf, pos, len);
        if (runtime.is1_9() || runtime.is2_0()) {
          ((RubyString) requestUrl).cat(data, 0, data.length, UTF8);
        } else {
          ((RubyString) requestUrl).cat(data);
        }
        return 0;
      }
    };

    this.settings.on_header_field = new HTTPDataCallback() {
      public int cb(http_parser.lolevel.HTTPParser p, ByteBuffer buf, int pos, int len) {
        byte[] data = fetchBytes(buf, pos, len);

        if (_current_header == null)
          _current_header = data;
        else {
          byte[] tmp = new byte[_current_header.length + data.length];
          System.arraycopy(_current_header, 0, tmp, 0, _current_header.length);
          System.arraycopy(data, 0, tmp, _current_header.length, data.length);
          _current_header = tmp;
        }

        return 0;
      }
    };
    final RubySymbol arraysSym = runtime.newSymbol("arrays");
    final RubySymbol mixedSym = runtime.newSymbol("mixed");
    final RubySymbol stopSym = runtime.newSymbol("stop");
    final RubySymbol resetSym = runtime.newSymbol("reset");
    this.settings.on_header_value = new HTTPDataCallback() {
      public int cb(http_parser.lolevel.HTTPParser p, ByteBuffer buf, int pos, int len) {
        byte[] data = fetchBytes(buf, pos, len);
        ThreadContext context = headers.getRuntime().getCurrentContext();
        IRubyObject key, val;
        int new_field = 0;

        if (_current_header != null) {
          new_field = 1;
          _last_header = _current_header;
          _current_header = null;
        }

        key = RubyString.newString(runtime, new ByteList(_last_header, UTF8, false));
        val = headers.op_aref(context, key);

        if (new_field == 1) {
          if (val.isNil()) {
            if (header_value_type == arraysSym) {
              headers.op_aset(context, key,
                  RubyArray.newArrayLight(runtime, RubyString.newStringLight(runtime, 10, UTF8)));
            } else {
              headers.op_aset(context, key, RubyString.newStringLight(runtime, 10, UTF8));
            }
          } else {
            if (header_value_type == mixedSym) {
              if (val instanceof RubyString) {
                headers.op_aset(context, key,
                    RubyArray.newArrayLight(runtime, val, RubyString.newStringLight(runtime, 10, UTF8)));
              } else {
                ((RubyArray) val).add(RubyString.newStringLight(runtime, 10, UTF8));
              }
            } else if (header_value_type == arraysSym) {
              ((RubyArray) val).add(RubyString.newStringLight(runtime, 10, UTF8));
            } else {
              if (runtime.is1_9() || runtime.is2_0()) {
                ((RubyString) val).cat(',', UTF8).cat(' ', UTF8);
              } else {
                ((RubyString) val).cat(',').cat(' ');
              }
            }
          }
          val = headers.op_aref(context, key);
        }

        if (val instanceof RubyArray) {
          val = ((RubyArray) val).entry(-1);
        }

        if (runtime.is1_9() || runtime.is2_0()) {
          ((RubyString) val).cat(data, 0, data.length, UTF8);
        } else {
          ((RubyString) val).cat(data);
        }

        return 0;
      }
    };

    this.settings.on_message_begin = new HTTPCallback() {
      public int cb(http_parser.lolevel.HTTPParser p) {
        headers = new RubyHash(runtime);

        if (runtime.is1_9() || runtime.is2_0()) {
          requestUrl = RubyString.newEmptyString(runtime, UTF8);
          requestPath = RubyString.newEmptyString(runtime, UTF8);
          queryString = RubyString.newEmptyString(runtime, UTF8);
          fragment = RubyString.newEmptyString(runtime, UTF8);
          upgradeData = RubyString.newEmptyString(runtime, UTF8);
        } else {
          requestUrl = RubyString.newEmptyString(runtime);
          requestPath = RubyString.newEmptyString(runtime);
          queryString = RubyString.newEmptyString(runtime);
          fragment = RubyString.newEmptyString(runtime);
          upgradeData = RubyString.newEmptyString(runtime);
        }

        IRubyObject ret = runtime.getNil();

        if (callback_object != null) {
          if (((RubyObject) callback_object).respondsTo("on_message_begin")) {
            ThreadContext context = callback_object.getRuntime().getCurrentContext();
            ret = callback_object.callMethod(context, "on_message_begin");
          }
        } else if (on_message_begin != null) {
          ThreadContext context = on_message_begin.getRuntime().getCurrentContext();
          ret = on_message_begin.callMethod(context, "call");
        }

        if (ret == stopSym) {
          throw new StopException();
        } else {
          return 0;
        }
      }
    };
    this.settings.on_message_complete = new HTTPCallback() {
      public int cb(http_parser.lolevel.HTTPParser p) {
        IRubyObject ret = runtime.getNil();

        completed = true;

        if (callback_object != null) {
          if (((RubyObject) callback_object).respondsTo("on_message_complete")) {
            ThreadContext context = callback_object.getRuntime().getCurrentContext();
            ret = callback_object.callMethod(context, "on_message_complete");
          }
        } else if (on_message_complete != null) {
          ThreadContext context = on_message_complete.getRuntime().getCurrentContext();
          ret = on_message_complete.callMethod(context, "call");
        }

        if (ret == stopSym) {
          throw new StopException();
        } else {
          return 0;
        }
      }
    };
    this.settings.on_headers_complete = new HTTPCallback() {
      public int cb(http_parser.lolevel.HTTPParser p) {
        IRubyObject ret = runtime.getNil();

        if (callback_object != null) {
          if (((RubyObject) callback_object).respondsTo("on_headers_complete")) {
            ThreadContext context = callback_object.getRuntime().getCurrentContext();
            ret = callback_object.callMethod(context, "on_headers_complete", headers);
          }
        } else if (on_headers_complete != null) {
          ThreadContext context = on_headers_complete.getRuntime().getCurrentContext();
          ret = on_headers_complete.callMethod(context, "call", headers);
        }

        if (ret == stopSym) {
          throw new StopException();
        } else if (ret == resetSym) {
          return 1;
        } else {
          return 0;
        }
      }
    };
    this.settings.on_body = new HTTPDataCallback() {
      public int cb(http_parser.lolevel.HTTPParser p, ByteBuffer buf, int pos, int len) {
        IRubyObject ret = runtime.getNil();
        byte[] data = fetchBytes(buf, pos, len);

        if (callback_object != null) {
          if (((RubyObject) callback_object).respondsTo("on_body")) {
            ThreadContext context = callback_object.getRuntime().getCurrentContext();
            ret = callback_object.callMethod(context, "on_body",
                RubyString.newString(runtime, new ByteList(data, UTF8, false)));
          }
        } else if (on_body != null) {
          ThreadContext context = on_body.getRuntime().getCurrentContext();
          ret = on_body.callMethod(context, "call", RubyString.newString(runtime, new ByteList(data, UTF8, false)));
        }

        if (ret == stopSym) {
          throw new StopException();
        } else {
          return 0;
        }
      }
    };
  }

  private void init() {
    this.parser = new HTTPParser();
    this.parser.HTTP_PARSER_STRICT = true;
    this.headers = null;

    this.requestUrl = runtime.getNil();
    this.requestPath = runtime.getNil();
    this.queryString = runtime.getNil();
    this.fragment = runtime.getNil();

    this.upgradeData = runtime.getNil();
  }

  @JRubyMethod(name = "initialize")
  public IRubyObject initialize() {
    return this;
  }

  @JRubyMethod(name = "initialize")
  public IRubyObject initialize(IRubyObject arg) {
    callback_object = arg;
    return initialize();
  }

  @JRubyMethod(name = "initialize")
  public IRubyObject initialize(IRubyObject arg, IRubyObject arg2) {
    header_value_type = arg2;
    return initialize(arg);
  }

  @JRubyMethod(name = "on_message_begin=")
  public IRubyObject set_on_message_begin(IRubyObject cb) {
    on_message_begin = cb;
    return cb;
  }

  @JRubyMethod(name = "on_headers_complete=")
  public IRubyObject set_on_headers_complete(IRubyObject cb) {
    on_headers_complete = cb;
    return cb;
  }

  @JRubyMethod(name = "on_body=")
  public IRubyObject set_on_body(IRubyObject cb) {
    on_body = cb;
    return cb;
  }

  @JRubyMethod(name = "on_message_complete=")
  public IRubyObject set_on_message_complete(IRubyObject cb) {
    on_message_complete = cb;
    return cb;
  }

  @JRubyMethod(name = "<<")
  public IRubyObject execute(IRubyObject data) {
    RubyString str = (RubyString) data;
    ByteList byteList = str.getByteList();
    ByteBuffer buf = ByteBuffer.wrap(byteList.getUnsafeBytes(), byteList.getBegin(), byteList.getRealSize());
    boolean stopped = false;

    try {
      this.parser.execute(this.settings, buf);
    } catch (HTTPException e) {
      throw new RaiseException(runtime, eParserError, e.getMessage(), true);
    } catch (StopException e) {
      stopped = true;
    }

    if (parser.getUpgrade()) {
      byte[] upData = fetchBytes(buf, buf.position(), buf.limit() - buf.position());
      if (runtime.is1_9() || runtime.is2_0()) {
        ((RubyString) upgradeData).cat(upData, 0, upData.length, UTF8);
      } else {
        ((RubyString) upgradeData).cat(upData);
      }
    } else if (buf.hasRemaining() && !completed) {
      if (!stopped)
        throw new RaiseException(runtime, eParserError, "Could not parse data entirely", true);
    }

    return RubyNumeric.int2fix(runtime, buf.position());
  }

  @JRubyMethod(name = "keep_alive?")
  public IRubyObject shouldKeepAlive() {
    return runtime.newBoolean(parser.shouldKeepAlive());
  }

  @JRubyMethod(name = "upgrade?")
  public IRubyObject shouldUpgrade() {
    return runtime.newBoolean(parser.getUpgrade());
  }

  @JRubyMethod(name = "http_major")
  public IRubyObject httpMajor() {
    if (parser.getMajor() == 0 && parser.getMinor() == 0)
      return runtime.getNil();
    else
      return RubyNumeric.int2fix(runtime, parser.getMajor());
  }

  @JRubyMethod(name = "http_minor")
  public IRubyObject httpMinor() {
    if (parser.getMajor() == 0 && parser.getMinor() == 0)
      return runtime.getNil();
    else
      return RubyNumeric.int2fix(runtime, parser.getMinor());
  }

  @JRubyMethod(name = "http_version")
  public IRubyObject httpVersion() {
    if (parser.getMajor() == 0 && parser.getMinor() == 0)
      return runtime.getNil();
    else
      return runtime.newArray(httpMajor(), httpMinor());
  }

  @JRubyMethod(name = "http_method")
  public IRubyObject httpMethod() {
    HTTPMethod method = parser.getHTTPMethod();
    if (method != null)
      return runtime.newString(new String(method.bytes));
    else
      return runtime.getNil();
  }

  @JRubyMethod(name = "status_code")
  public IRubyObject statusCode() {
    int code = parser.getStatusCode();
    if (code != 0)
      return RubyNumeric.int2fix(runtime, code);
    else
      return runtime.getNil();
  }

  @JRubyMethod(name = "headers")
  public IRubyObject getHeaders() {
    return headers == null ? runtime.getNil() : headers;
  }

  @JRubyMethod(name = "request_url")
  public IRubyObject getRequestUrl() {
    return requestUrl == null ? runtime.getNil() : requestUrl;
  }

  @JRubyMethod(name = "request_path")
  public IRubyObject getRequestPath() {
    return requestPath == null ? runtime.getNil() : requestPath;
  }

  @JRubyMethod(name = "query_string")
  public IRubyObject getQueryString() {
    return queryString == null ? runtime.getNil() : queryString;
  }

  @JRubyMethod(name = "fragment")
  public IRubyObject getFragment() {
    return fragment == null ? runtime.getNil() : fragment;
  }

  @JRubyMethod(name = "header_value_type")
  public IRubyObject getHeaderValueType() {
    return header_value_type == null ? runtime.getNil() : header_value_type;
  }

  @JRubyMethod(name = "header_value_type=")
  public IRubyObject set_header_value_type(IRubyObject val) {
    String valString = val.toString();
    if (valString != "mixed" && valString != "arrays" && valString != "strings") {
      throw runtime.newArgumentError("Invalid header value type");
    }
    header_value_type = val;
    return val;
  }

  @JRubyMethod(name = "upgrade_data")
  public IRubyObject upgradeData() {
    return upgradeData == null ? runtime.getNil() : upgradeData;
  }

  @JRubyMethod(name = "reset!")
  public IRubyObject reset() {
    init();
    return runtime.getTrue();
  }

}
