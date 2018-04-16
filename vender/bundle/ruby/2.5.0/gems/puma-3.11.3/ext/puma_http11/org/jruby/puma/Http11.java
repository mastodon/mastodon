package org.jruby.puma;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyHash;
import org.jruby.RubyModule;
import org.jruby.RubyNumeric;
import org.jruby.RubyObject;
import org.jruby.RubyString;

import org.jruby.anno.JRubyMethod;

import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;

import org.jruby.exceptions.RaiseException;

import org.jruby.util.ByteList;

/**
 * @author <a href="mailto:ola.bini@ki.se">Ola Bini</a>
 */
public class Http11 extends RubyObject {
    public final static int MAX_FIELD_NAME_LENGTH = 256;
    public final static String MAX_FIELD_NAME_LENGTH_ERR = "HTTP element FIELD_NAME is longer than the 256 allowed length.";
    public final static int MAX_FIELD_VALUE_LENGTH = 80 * 1024;
    public final static String MAX_FIELD_VALUE_LENGTH_ERR = "HTTP element FIELD_VALUE is longer than the 81920 allowed length.";
    public final static int MAX_REQUEST_URI_LENGTH = 1024 * 12;
    public final static String MAX_REQUEST_URI_LENGTH_ERR = "HTTP element REQUEST_URI is longer than the 12288 allowed length.";
    public final static int MAX_FRAGMENT_LENGTH = 1024;
    public final static String MAX_FRAGMENT_LENGTH_ERR = "HTTP element REQUEST_PATH is longer than the 1024 allowed length.";
    public final static int MAX_REQUEST_PATH_LENGTH = 2048;
    public final static String MAX_REQUEST_PATH_LENGTH_ERR = "HTTP element REQUEST_PATH is longer than the 2048 allowed length.";
    public final static int MAX_QUERY_STRING_LENGTH = 1024 * 10;
    public final static String MAX_QUERY_STRING_LENGTH_ERR = "HTTP element QUERY_STRING is longer than the 10240 allowed length.";
    public final static int MAX_HEADER_LENGTH = 1024 * (80 + 32);
    public final static String MAX_HEADER_LENGTH_ERR = "HTTP element HEADER is longer than the 114688 allowed length.";


    private static ObjectAllocator ALLOCATOR = new ObjectAllocator() {
        public IRubyObject allocate(Ruby runtime, RubyClass klass) {
            return new Http11(runtime, klass);
        }
    };

    public static void createHttp11(Ruby runtime) {
        RubyModule mPuma = runtime.defineModule("Puma");
        mPuma.defineClassUnder("HttpParserError",runtime.getClass("IOError"),runtime.getClass("IOError").getAllocator());

        RubyClass cHttpParser = mPuma.defineClassUnder("HttpParser",runtime.getObject(),ALLOCATOR);
        cHttpParser.defineAnnotatedMethods(Http11.class);
    }

    private Ruby runtime;
    private RubyClass eHttpParserError;
    private Http11Parser hp;
    private RubyString body;

    public Http11(Ruby runtime, RubyClass clazz) {
        super(runtime,clazz);
        this.runtime = runtime;
        this.eHttpParserError = (RubyClass)runtime.getModule("Puma").getConstant("HttpParserError");
        this.hp = new Http11Parser();
        this.hp.parser.http_field = http_field;
        this.hp.parser.request_method = request_method;
        this.hp.parser.request_uri = request_uri;
        this.hp.parser.fragment = fragment;
        this.hp.parser.request_path = request_path;
        this.hp.parser.query_string = query_string;
        this.hp.parser.http_version = http_version;
        this.hp.parser.header_done = header_done;
        this.hp.parser.init();
    }

    public void validateMaxLength(int len, int max, String msg) {
        if(len>max) {
            throw new RaiseException(runtime, eHttpParserError, msg, true);
        }
    }

    private Http11Parser.FieldCB http_field = new Http11Parser.FieldCB() {
            public void call(Object data, int field, int flen, int value, int vlen) {
                RubyHash req = (RubyHash)data;
                RubyString f;
                IRubyObject v;
                validateMaxLength(flen, MAX_FIELD_NAME_LENGTH, MAX_FIELD_NAME_LENGTH_ERR);
                validateMaxLength(vlen, MAX_FIELD_VALUE_LENGTH, MAX_FIELD_VALUE_LENGTH_ERR);

                ByteList b = new ByteList(Http11.this.hp.parser.buffer,field,flen);
                for(int i = 0,j = b.length();i<j;i++) {
                    if((b.get(i) & 0xFF) == '-') {
                        b.set(i, (byte)'_');
                    } else {
                        b.set(i, (byte)Character.toUpperCase((char)b.get(i)));
                    }
                }

                String as = b.toString();

                if(as.equals("CONTENT_LENGTH") || as.equals("CONTENT_TYPE")) {
                  f = RubyString.newString(runtime, b);
                } else {
                  f = RubyString.newString(runtime, "HTTP_");
                  f.cat(b);
                }

                b = new ByteList(Http11.this.hp.parser.buffer, value, vlen);
                v = req.op_aref(req.getRuntime().getCurrentContext(), f);
                if (v.isNil()) {
                    req.op_aset(req.getRuntime().getCurrentContext(), f, RubyString.newString(runtime, b));
                } else {
                    RubyString vs = v.convertToString();
                    vs.cat(RubyString.newString(runtime, ", "));
                    vs.cat(b);
                }
            }
        };

    private Http11Parser.ElementCB request_method = new Http11Parser.ElementCB() {
            public void call(Object data, int at, int length) {
                RubyHash req = (RubyHash)data;
                RubyString val = RubyString.newString(runtime,new ByteList(hp.parser.buffer,at,length));
                req.op_aset(req.getRuntime().getCurrentContext(), runtime.newString("REQUEST_METHOD"),val);
            }
        };

    private Http11Parser.ElementCB request_uri = new Http11Parser.ElementCB() {
            public void call(Object data, int at, int length) {
                RubyHash req = (RubyHash)data;
                validateMaxLength(length, MAX_REQUEST_URI_LENGTH, MAX_REQUEST_URI_LENGTH_ERR);
                RubyString val = RubyString.newString(runtime,new ByteList(hp.parser.buffer,at,length));
                req.op_aset(req.getRuntime().getCurrentContext(), runtime.newString("REQUEST_URI"),val);
            }
        };

    private Http11Parser.ElementCB fragment = new Http11Parser.ElementCB() {
            public void call(Object data, int at, int length) {
                RubyHash req = (RubyHash)data;
                validateMaxLength(length, MAX_FRAGMENT_LENGTH, MAX_FRAGMENT_LENGTH_ERR);
                RubyString val = RubyString.newString(runtime,new ByteList(hp.parser.buffer,at,length));
                req.op_aset(req.getRuntime().getCurrentContext(), runtime.newString("FRAGMENT"),val);
            }
        };

    private Http11Parser.ElementCB request_path = new Http11Parser.ElementCB() {
            public void call(Object data, int at, int length) {
                RubyHash req = (RubyHash)data;
                validateMaxLength(length, MAX_REQUEST_PATH_LENGTH, MAX_REQUEST_PATH_LENGTH_ERR);
                RubyString val = RubyString.newString(runtime,new ByteList(hp.parser.buffer,at,length));
                req.op_aset(req.getRuntime().getCurrentContext(), runtime.newString("REQUEST_PATH"),val);
            }
        };

    private Http11Parser.ElementCB query_string = new Http11Parser.ElementCB() {
            public void call(Object data, int at, int length) {
                RubyHash req = (RubyHash)data;
                validateMaxLength(length, MAX_QUERY_STRING_LENGTH, MAX_QUERY_STRING_LENGTH_ERR);
                RubyString val = RubyString.newString(runtime,new ByteList(hp.parser.buffer,at,length));
                req.op_aset(req.getRuntime().getCurrentContext(), runtime.newString("QUERY_STRING"),val);
            }
        };

    private Http11Parser.ElementCB http_version = new Http11Parser.ElementCB() {
            public void call(Object data, int at, int length) {
                RubyHash req = (RubyHash)data;
                RubyString val = RubyString.newString(runtime,new ByteList(hp.parser.buffer,at,length));
                req.op_aset(req.getRuntime().getCurrentContext(), runtime.newString("HTTP_VERSION"),val);
            }
        };

    private Http11Parser.ElementCB header_done = new Http11Parser.ElementCB() {
            public void call(Object data, int at, int length) {
                body = RubyString.newString(runtime, new ByteList(hp.parser.buffer, at, length));
            }
        };

    @JRubyMethod
    public IRubyObject initialize() {
        this.hp.parser.init();
        return this;
    }

    @JRubyMethod
    public IRubyObject reset() {
        this.hp.parser.init();
        return runtime.getNil();
    }

    @JRubyMethod
    public IRubyObject finish() {
        this.hp.finish();
        return this.hp.is_finished() ? runtime.getTrue() : runtime.getFalse();
    }

    @JRubyMethod
    public IRubyObject execute(IRubyObject req_hash, IRubyObject data, IRubyObject start) {
        int from = 0;
        from = RubyNumeric.fix2int(start);
        ByteList d = ((RubyString)data).getByteList();
        if(from >= d.length()) {
            throw new RaiseException(runtime, eHttpParserError, "Requested start is after data buffer end.", true);
        } else {
            this.hp.parser.data = req_hash;
            this.hp.execute(d,from);
            validateMaxLength(this.hp.parser.nread,MAX_HEADER_LENGTH, MAX_HEADER_LENGTH_ERR);
            if(this.hp.has_error()) {
                throw new RaiseException(runtime, eHttpParserError, "Invalid HTTP format, parsing fails.", true);
            } else {
                return runtime.newFixnum(this.hp.parser.nread);
            }
        }
    }

    @JRubyMethod(name = "error?")
    public IRubyObject has_error() {
        return this.hp.has_error() ? runtime.getTrue() : runtime.getFalse();
    }

    @JRubyMethod(name = "finished?")
    public IRubyObject is_finished() {
        return this.hp.is_finished() ? runtime.getTrue() : runtime.getFalse();
    }

    @JRubyMethod
    public IRubyObject nread() {
        return runtime.newFixnum(this.hp.parser.nread);
    }
    
    @JRubyMethod
    public IRubyObject body() {
        return body;
    }
}// Http11
