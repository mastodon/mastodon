package org.msgpack.jruby;


import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyClass;
import org.jruby.RubyObject;
import org.jruby.RubyArray;
import org.jruby.RubyHash;
import org.jruby.RubyIO;
import org.jruby.RubyNumeric;
import org.jruby.RubyInteger;
import org.jruby.RubyFixnum;
import org.jruby.runtime.Block;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.util.ByteList;
import org.jruby.util.TypeConverter;
import org.msgpack.jruby.ExtensionValue;

import static org.jruby.runtime.Visibility.PRIVATE;

@JRubyClass(name="MessagePack::Packer")
public class Packer extends RubyObject {
  public ExtensionRegistry registry;
  private Buffer buffer;
  private Encoder encoder;
  private boolean hasSymbolExtType;

  public Packer(Ruby runtime, RubyClass type, ExtensionRegistry registry, boolean hasSymbolExtType) {
    super(runtime, type);
    this.registry = registry;
    this.hasSymbolExtType = hasSymbolExtType;
  }

  static class PackerAllocator implements ObjectAllocator {
    public IRubyObject allocate(Ruby runtime, RubyClass type) {
      return new Packer(runtime, type, null, false);
    }
  }

  @JRubyMethod(name = "initialize", optional = 2)
  public IRubyObject initialize(ThreadContext ctx, IRubyObject[] args) {
    boolean compatibilityMode = false;
    if (args.length > 0 && args[args.length - 1] instanceof RubyHash) {
      RubyHash options = (RubyHash) args[args.length - 1];
      IRubyObject mode = options.fastARef(ctx.getRuntime().newSymbol("compatibility_mode"));
      compatibilityMode = (mode != null) && mode.isTrue();
    }
    if (registry == null) {
        // registry is null when allocate -> initialize
        // registry is already initialized (and somthing might be registered) when newPacker from Factory
        this.registry = new ExtensionRegistry();
    }
    this.encoder = new Encoder(ctx.getRuntime(), compatibilityMode, registry, hasSymbolExtType);
    this.buffer = new Buffer(ctx.getRuntime(), ctx.getRuntime().getModule("MessagePack").getClass("Buffer"));
    this.buffer.initialize(ctx, args);
    return this;
  }

  public static Packer newPacker(ThreadContext ctx, ExtensionRegistry extRegistry, boolean hasSymbolExtType, IRubyObject[] args) {
    Packer packer = new Packer(ctx.getRuntime(), ctx.getRuntime().getModule("MessagePack").getClass("Packer"), extRegistry, hasSymbolExtType);
    packer.initialize(ctx, args);
    return packer;
  }

  @JRubyMethod(name = "compatibility_mode?")
  public IRubyObject isCompatibilityMode(ThreadContext ctx) {
    return encoder.isCompatibilityMode() ? ctx.getRuntime().getTrue() : ctx.getRuntime().getFalse();
  }

  @JRubyMethod(name = "registered_types_internal", visibility = PRIVATE)
  public IRubyObject registeredTypesInternal(ThreadContext ctx) {
    return registry.toInternalPackerRegistry(ctx);
  }

  @JRubyMethod(name = "register_type", required = 2, optional = 1)
  public IRubyObject registerType(ThreadContext ctx, IRubyObject[] args, final Block block) {
    Ruby runtime = ctx.getRuntime();
    IRubyObject type = args[0];
    IRubyObject mod = args[1];

    IRubyObject arg;
    IRubyObject proc;
    if (args.length == 2) {
      if (! block.isGiven()) {
        throw runtime.newLocalJumpErrorNoBlock();
      }
      proc = block.getProcObject();
      arg = proc;
    } else if (args.length == 3) {
      arg = args[2];
      proc = arg.callMethod(ctx, "to_proc");
    } else {
      throw runtime.newArgumentError(String.format("wrong number of arguments (%d for 2..3)", 2 + args.length));
    }

    long typeId = ((RubyFixnum) type).getLongValue();
    if (typeId < -128 || typeId > 127) {
      throw runtime.newRangeError(String.format("integer %d too big to convert to `signed char'", typeId));
    }

    if (!(mod instanceof RubyModule)) {
      throw runtime.newArgumentError(String.format("expected Module/Class but found %s.", mod.getType().getName()));
    }
    RubyModule extModule = (RubyModule) mod;

    registry.put(extModule, (int) typeId, proc, arg, null, null);

    if (extModule == runtime.getSymbol()) {
      encoder.hasSymbolExtType = true;
    }

    return runtime.getNil();
  }

  @JRubyMethod(name = "write", alias = { "pack" })
  public IRubyObject write(ThreadContext ctx, IRubyObject obj) {
    buffer.write(ctx, encoder.encode(obj, this));
    return this;
  }

  @JRubyMethod(name = "write_float")
  public IRubyObject writeFloat(ThreadContext ctx, IRubyObject obj) {
    checkType(ctx, obj, org.jruby.RubyFloat.class);
    return write(ctx, obj);
  }

  @JRubyMethod(name = "write_array")
  public IRubyObject writeArray(ThreadContext ctx, IRubyObject obj) {
    checkType(ctx, obj, org.jruby.RubyArray.class);
    return write(ctx, obj);
  }

  @JRubyMethod(name = "write_string")
  public IRubyObject writeString(ThreadContext ctx, IRubyObject obj) {
    checkType(ctx, obj, org.jruby.RubyString.class);
    return write(ctx, obj);
  }

  @JRubyMethod(name = "write_hash")
  public IRubyObject writeHash(ThreadContext ctx, IRubyObject obj) {
    checkType(ctx, obj, org.jruby.RubyHash.class);
    return write(ctx, obj);
  }

  @JRubyMethod(name = "write_symbol")
  public IRubyObject writeSymbol(ThreadContext ctx, IRubyObject obj) {
    checkType(ctx, obj, org.jruby.RubySymbol.class);
    return write(ctx, obj);
  }

  @JRubyMethod(name = "write_int")
  public IRubyObject writeInt(ThreadContext ctx, IRubyObject obj) {
    if (!(obj instanceof RubyFixnum)) {
      checkType(ctx, obj, org.jruby.RubyBignum.class);
    }
    return write(ctx, obj);
  }

  @JRubyMethod(name = "write_extension")
  public IRubyObject writeExtension(ThreadContext ctx, IRubyObject obj) {
    if (!(obj instanceof ExtensionValue)) {
      throw ctx.runtime.newTypeError("Expected extension");
    }
    return write(ctx, obj);
  }

  @JRubyMethod(name = "write_true")
  public IRubyObject writeTrue(ThreadContext ctx) {
    return write(ctx, ctx.getRuntime().getTrue());
  }

  @JRubyMethod(name = "write_false")
  public IRubyObject writeFalse(ThreadContext ctx) {
    return write(ctx, ctx.getRuntime().getFalse());
  }

  @JRubyMethod(name = "write_nil")
  public IRubyObject writeNil(ThreadContext ctx) {
    write(ctx, null);
    return this;
  }

  @JRubyMethod(name = "write_float32")
  public IRubyObject writeFloat32(ThreadContext ctx, IRubyObject numeric) {
    Ruby runtime = ctx.runtime;
    if (!(numeric instanceof RubyNumeric)) {
      throw runtime.newArgumentError("Expected numeric");
    }
    buffer.write(ctx, encoder.encodeFloat32((RubyNumeric) numeric));
    return this;
  }

  @JRubyMethod(name = "write_array_header")
  public IRubyObject writeArrayHeader(ThreadContext ctx, IRubyObject size) {
    int s = (int) size.convertToInteger().getLongValue();
    buffer.write(ctx, encoder.encodeArrayHeader(s));
    return this;
  }

  @JRubyMethod(name = "write_map_header")
  public IRubyObject writeMapHeader(ThreadContext ctx, IRubyObject size) {
    int s = (int) size.convertToInteger().getLongValue();
    buffer.write(ctx, encoder.encodeMapHeader(s));
    return this;
  }

  @JRubyMethod(name = "full_pack")
  public IRubyObject fullPack(ThreadContext ctx) {
    return toS(ctx);
  }

  @JRubyMethod(name = "to_s", alias = { "to_str" })
  public IRubyObject toS(ThreadContext ctx) {
    return buffer.toS(ctx);
  }

  @JRubyMethod(name = "buffer")
  public IRubyObject buffer(ThreadContext ctx) {
    return buffer;
  }

  @JRubyMethod(name = "flush")
  public IRubyObject flush(ThreadContext ctx) {
    return buffer.flush(ctx);
  }

  @JRubyMethod(name = "size")
  public IRubyObject size(ThreadContext ctx) {
    return buffer.size(ctx);
  }

  @JRubyMethod(name = "clear")
  public IRubyObject clear(ThreadContext ctx) {
    return buffer.clear(ctx);
  }

  private void checkType(ThreadContext ctx, IRubyObject obj, Class<? extends IRubyObject> expectedType) {
    if (!expectedType.isInstance(obj)) {
      String expectedName = expectedType.getName().substring("org.jruby.Ruby".length());
      throw ctx.runtime.newTypeError(String.format("wrong argument type %s (expected %s)", obj.getMetaClass().toString(), expectedName));
    }
  }
}
