package org.msgpack.jruby;

import java.util.Arrays;

import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyClass;
import org.jruby.RubyString;
import org.jruby.RubyObject;
import org.jruby.RubyArray;
import org.jruby.RubyHash;
import org.jruby.RubyNumeric;
import org.jruby.RubyFixnum;
import org.jruby.RubyProc;
import org.jruby.RubyIO;
import org.jruby.exceptions.RaiseException;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.Block;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.ThreadContext;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.util.ByteList;
import org.jruby.ext.stringio.StringIO;

import static org.jruby.runtime.Visibility.PRIVATE;

@JRubyClass(name="MessagePack::Unpacker")
public class Unpacker extends RubyObject {
  private final ExtensionRegistry registry;

  private IRubyObject stream;
  private IRubyObject data;
  private Decoder decoder;
  private final RubyClass underflowErrorClass;
  private boolean symbolizeKeys;
  private boolean allowUnknownExt;

  public Unpacker(Ruby runtime, RubyClass type) {
    this(runtime, type, new ExtensionRegistry());
  }

  public Unpacker(Ruby runtime, RubyClass type, ExtensionRegistry registry) {
    super(runtime, type);
    this.registry = registry;
    this.underflowErrorClass = runtime.getModule("MessagePack").getClass("UnderflowError");
  }

  static class UnpackerAllocator implements ObjectAllocator {
    public IRubyObject allocate(Ruby runtime, RubyClass klass) {
      return new Unpacker(runtime, klass);
    }
  }

  @JRubyMethod(name = "initialize", optional = 2, visibility = PRIVATE)
  public IRubyObject initialize(ThreadContext ctx, IRubyObject[] args) {
    symbolizeKeys = false;
    allowUnknownExt = false;
    if (args.length > 0) {
      if (args[args.length - 1] instanceof RubyHash) {
        RubyHash options = (RubyHash) args[args.length - 1];
        IRubyObject sk = options.fastARef(ctx.getRuntime().newSymbol("symbolize_keys"));
        if (sk != null) {
          symbolizeKeys = sk.isTrue();
        }
        IRubyObject au = options.fastARef(ctx.getRuntime().newSymbol("allow_unknown_ext"));
        if (au != null) {
          allowUnknownExt = au.isTrue();
        }
      }
      if (args[0] != ctx.getRuntime().getNil() && !(args[0] instanceof RubyHash)) {
        setStream(ctx, args[0]);
      }
    }
    return this;
  }

  public static Unpacker newUnpacker(ThreadContext ctx, ExtensionRegistry extRegistry, IRubyObject[] args) {
    Unpacker unpacker = new Unpacker(ctx.getRuntime(), ctx.getRuntime().getModule("MessagePack").getClass("Unpacker"), extRegistry);
    unpacker.initialize(ctx, args);
    return unpacker;
  }

  @JRubyMethod(name = "symbolize_keys?")
  public IRubyObject isSymbolizeKeys(ThreadContext ctx) {
    return symbolizeKeys ? ctx.getRuntime().getTrue() : ctx.getRuntime().getFalse();
  }

  @JRubyMethod(name = "allow_unknown_ext?")
  public IRubyObject isAllowUnknownExt(ThreadContext ctx) {
    return allowUnknownExt ? ctx.getRuntime().getTrue() : ctx.getRuntime().getFalse();
  }

  @JRubyMethod(name = "registered_types_internal", visibility = PRIVATE)
  public IRubyObject registeredTypesInternal(ThreadContext ctx) {
    return registry.toInternalUnpackerRegistry(ctx);
  }

  @JRubyMethod(name = "register_type", required = 1, optional = 2)
  public IRubyObject registerType(ThreadContext ctx, IRubyObject[] args, final Block block) {
    Ruby runtime = ctx.getRuntime();
    IRubyObject type = args[0];

    RubyModule extModule;
    IRubyObject arg;
    IRubyObject proc;
    if (args.length == 1) {
      if (! block.isGiven()) {
        throw runtime.newLocalJumpErrorNoBlock();
      }
      proc = RubyProc.newProc(runtime, block, block.type);
      if (proc == null)
        System.err.println("proc from Block is null");
      arg = proc;
      extModule = null;
    } else if (args.length == 3) {
      extModule = (RubyModule) args[1];
      arg = args[2];
      proc = extModule.method(arg);
    } else {
      throw runtime.newArgumentError(String.format("wrong number of arguments (%d for 1 or 3)", 2 + args.length));
    }

    long typeId = ((RubyFixnum) type).getLongValue();
    if (typeId < -128 || typeId > 127) {
      throw runtime.newRangeError(String.format("integer %d too big to convert to `signed char'", typeId));
    }

    registry.put(extModule, (int) typeId, null, null, proc, arg);
    return runtime.getNil();
  }

  @JRubyMethod(required = 2)
  public IRubyObject execute(ThreadContext ctx, IRubyObject data, IRubyObject offset) {
    return executeLimit(ctx, data, offset, null);
  }

  @JRubyMethod(name = "execute_limit", required = 3)
  public IRubyObject executeLimit(ThreadContext ctx, IRubyObject str, IRubyObject off, IRubyObject lim) {
    RubyString input = str.asString();
    int offset = RubyNumeric.fix2int(off);
    int limit = lim == null || lim.isNil() ? -1 : RubyNumeric.fix2int(lim);
    ByteList byteList = input.getByteList();
    if (limit == -1) {
      limit = byteList.length() - offset;
    }
    Decoder decoder = new Decoder(ctx.getRuntime(), registry, byteList.unsafeBytes(), byteList.begin() + offset, limit, symbolizeKeys, allowUnknownExt);
    try {
      data = null;
      data = decoder.next();
    } catch (RaiseException re) {
      if (re.getException().getType() != underflowErrorClass) {
        throw re;
      }
    }
    return ctx.getRuntime().newFixnum(decoder.offset());
  }

  @JRubyMethod(name = "data")
  public IRubyObject getData(ThreadContext ctx) {
    if (data == null) {
      return ctx.getRuntime().getNil();
    } else {
      return data;
    }
  }

  @JRubyMethod(name = "finished?")
  public IRubyObject finished_p(ThreadContext ctx) {
    return data == null ? ctx.getRuntime().getFalse() : ctx.getRuntime().getTrue();
  }

  @JRubyMethod(required = 1)
  public IRubyObject feed(ThreadContext ctx, IRubyObject data) {
    ByteList byteList = data.asString().getByteList();
    if (decoder == null) {
      decoder = new Decoder(ctx.getRuntime(), registry, byteList.unsafeBytes(), byteList.begin(), byteList.length(), symbolizeKeys, allowUnknownExt);
    } else {
      decoder.feed(byteList.unsafeBytes(), byteList.begin(), byteList.length());
    }
    return this;
  }

  @JRubyMethod(name = "full_unpack")
  public IRubyObject fullUnpack(ThreadContext ctx) {
    return decoder.next();
  }

  @JRubyMethod(name = "feed_each", required = 1)
  public IRubyObject feedEach(ThreadContext ctx, IRubyObject data, Block block) {
    feed(ctx, data);
    if (block.isGiven()) {
      each(ctx, block);
      return ctx.getRuntime().getNil();
    } else {
      return callMethod(ctx, "to_enum");
    }
  }

  @JRubyMethod
  public IRubyObject each(ThreadContext ctx, Block block) {
    if (block.isGiven()) {
      if (decoder != null) {
        try {
          while (decoder.hasNext()) {
            block.yield(ctx, decoder.next());
          }
        } catch (RaiseException re) {
          if (re.getException().getType() != underflowErrorClass) {
            throw re;
          }
        }
      }
      return this;
    } else {
      return callMethod(ctx, "to_enum");
    }
  }

  @JRubyMethod
  public IRubyObject fill(ThreadContext ctx) {
    return ctx.getRuntime().getNil();
  }

  @JRubyMethod
  public IRubyObject reset(ThreadContext ctx) {
    if (decoder != null) {
      decoder.reset();
    }
    return ctx.getRuntime().getNil();
  }

  @JRubyMethod(name = "read", alias = { "unpack" })
  public IRubyObject read(ThreadContext ctx) {
    if (decoder == null) {
      throw ctx.getRuntime().newEOFError();
    }
    try {
      return decoder.next();
    } catch (RaiseException re) {
      if (re.getException().getType() != underflowErrorClass) {
        throw re;
      } else {
        throw ctx.getRuntime().newEOFError();
      }
    }
  }

  @JRubyMethod(name = "skip")
  public IRubyObject skip(ThreadContext ctx) {
    throw ctx.getRuntime().newNotImplementedError("Not supported yet in JRuby implementation");
  }

  @JRubyMethod(name = "skip_nil")
  public IRubyObject skipNil(ThreadContext ctx) {
    throw ctx.getRuntime().newNotImplementedError("Not supported yet in JRuby implementation");
  }

  @JRubyMethod
  public IRubyObject read_array_header(ThreadContext ctx) {
    if (decoder != null) {
      try {
        return decoder.read_array_header();
      } catch (RaiseException re) {
        if (re.getException().getType() != underflowErrorClass) {
          throw re;
        } else {
          throw ctx.getRuntime().newEOFError();
        }
      }
    }
    return ctx.getRuntime().getNil();
  }

  @JRubyMethod
  public IRubyObject read_map_header(ThreadContext ctx) {
    if (decoder != null) {
      try {
        return decoder.read_map_header();
      } catch (RaiseException re) {
        if (re.getException().getType() != underflowErrorClass) {
          throw re;
        } else {
          throw ctx.getRuntime().newEOFError();
        }
      }
    }
    return ctx.getRuntime().getNil();
  }

  @JRubyMethod(name = "stream")
  public IRubyObject getStream(ThreadContext ctx) {
    if (stream == null) {
      return ctx.getRuntime().getNil();
    } else {
      return stream;
    }
  }

  @JRubyMethod(name = "stream=", required = 1)
  public IRubyObject setStream(ThreadContext ctx, IRubyObject stream) {
    RubyString str;
    if (stream instanceof StringIO) {
      str = stream.callMethod(ctx, "string").asString();
    } else if (stream instanceof RubyIO) {
      str = stream.callMethod(ctx, "read").asString();
    } else if (stream.respondsTo("read")) {
      str = stream.callMethod(ctx, "read").asString();
    } else {
      throw ctx.getRuntime().newTypeError(stream, "IO");
    }
    ByteList byteList = str.getByteList();
    this.stream = stream;
    this.decoder = null;
    this.decoder = new Decoder(ctx.getRuntime(), registry, byteList.unsafeBytes(), byteList.begin(), byteList.length(), symbolizeKeys, allowUnknownExt);
    return getStream(ctx);
  }
}
