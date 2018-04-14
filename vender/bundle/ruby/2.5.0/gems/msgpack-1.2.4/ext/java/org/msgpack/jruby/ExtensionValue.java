package org.msgpack.jruby;


import java.util.Arrays;
import java.nio.ByteBuffer;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyObject;
import org.jruby.RubyFixnum;
import org.jruby.RubyString;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.ThreadContext;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.util.ByteList;

import static org.jruby.runtime.Visibility.PRIVATE;

import org.jcodings.Encoding;

import static org.msgpack.jruby.Types.*;


@JRubyClass(name="MessagePack::ExtensionValue")
public class ExtensionValue extends RubyObject {
  private final Encoding binaryEncoding;

  private RubyFixnum type;
  private RubyString payload;

  public ExtensionValue(Ruby runtime, RubyClass type) {
    super(runtime, type);
    this.binaryEncoding = runtime.getEncodingService().getAscii8bitEncoding();
  }

  public static class ExtensionValueAllocator implements ObjectAllocator {
    public IRubyObject allocate(Ruby runtime, RubyClass klass) {
      return new ExtensionValue(runtime, klass);
    }
  }

  public static ExtensionValue newExtensionValue(Ruby runtime, int type, byte[] payload) {
    ExtensionValue v = new ExtensionValue(runtime, runtime.getModule("MessagePack").getClass("ExtensionValue"));
    ByteList byteList = new ByteList(payload, runtime.getEncodingService().getAscii8bitEncoding());
    v.initialize(runtime.getCurrentContext(), runtime.newFixnum(type), runtime.newString(byteList));
    return v;
  }

  @JRubyMethod(name = "initialize", required = 2, visibility = PRIVATE)
  public IRubyObject initialize(ThreadContext ctx, IRubyObject type, IRubyObject payload) {
    this.type = (RubyFixnum) type;
    this.payload = (RubyString) payload;
    return this;
  }

  @JRubyMethod(name = {"to_s", "inspect"})
  @Override
  public IRubyObject to_s() {
    IRubyObject payloadStr = payload.callMethod(getRuntime().getCurrentContext(), "inspect");
    return getRuntime().newString(String.format("#<MessagePack::ExtensionValue @type=%d, @payload=%s>", type.getLongValue(), payloadStr));
  }

  @JRubyMethod(name = "hash")
  @Override
  public RubyFixnum hash() {
    long hash = payload.hashCode() ^ (type.getLongValue() << 56);
    return RubyFixnum.newFixnum(getRuntime(), hash);
  }

  @JRubyMethod(name = "eql?")
  public IRubyObject eql_p(ThreadContext ctx, IRubyObject o) {
    Ruby runtime = ctx.runtime;
    if (this == o) {
	    return runtime.getTrue();
    }
    if (o instanceof ExtensionValue) {
      ExtensionValue other = (ExtensionValue) o;
      if (!this.type.eql_p(other.type).isTrue())
        return runtime.getFalse();
      if (runtime.is1_8()) {
        return this.payload.str_eql_p(ctx, other.payload);
      } else {
        return this.payload.str_eql_p19(ctx, other.payload);
      }
    }
    return runtime.getFalse();
  }

  @JRubyMethod(name = "==")
  public IRubyObject op_equal(ThreadContext ctx, IRubyObject o) {
    Ruby runtime = ctx.runtime;
    if (this == o) {
	    return runtime.getTrue();
    }
    if (o instanceof ExtensionValue) {
      ExtensionValue other = (ExtensionValue) o;
      if (!this.type.op_equal(ctx, other.type).isTrue())
        return runtime.getFalse();
      if (runtime.is1_8()) {
        return this.payload.op_equal(ctx, other.payload);
      } else {
        return this.payload.op_equal19(ctx, other.payload);
      }
    }
    return runtime.getFalse();
  }

  @JRubyMethod(name = "type")
  public IRubyObject get_type() {
    return type;
  }

  @JRubyMethod
  public IRubyObject payload() {
    return payload;
  }

  @JRubyMethod(name = "type=", required = 1)
  public IRubyObject set_type(final IRubyObject tpe) {
    type = (RubyFixnum)tpe;
    return tpe;
  }

  @JRubyMethod(name = "payload=", required = 1)
  public IRubyObject set_payload(final IRubyObject pld) {
    payload = (RubyString)pld;
    return pld;
  }
}
