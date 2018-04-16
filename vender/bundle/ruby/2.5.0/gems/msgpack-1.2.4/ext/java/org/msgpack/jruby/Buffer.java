package org.msgpack.jruby;


import java.nio.ByteBuffer;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyObject;
import org.jruby.RubyHash;
import org.jruby.RubyIO;
import org.jruby.RubyInteger;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.util.ByteList;

import org.jcodings.Encoding;


@JRubyClass(name="MessagePack::Buffer")
public class Buffer extends RubyObject {
  private IRubyObject io;
  private ByteBuffer buffer;
  private boolean writeMode;
  private Encoding binaryEncoding;

  private static final int CACHE_LINE_SIZE = 64;
  private static final int ARRAY_HEADER_SIZE = 24;

  public Buffer(Ruby runtime, RubyClass type) {
    super(runtime, type);
  }

  static class BufferAllocator implements ObjectAllocator {
    public IRubyObject allocate(Ruby runtime, RubyClass type) {
      return new Buffer(runtime, type);
    }
  }

  @JRubyMethod(name = "initialize", optional = 2)
  public IRubyObject initialize(ThreadContext ctx, IRubyObject[] args) {
    if (args.length > 0) {
      IRubyObject io = args[0];
      if (io.respondsTo("close") && (io.respondsTo("read") || (io.respondsTo("write") && io.respondsTo("flush")))) {
        this.io = io;
      }
    }
    this.buffer = ByteBuffer.allocate(CACHE_LINE_SIZE - ARRAY_HEADER_SIZE);
    this.writeMode = true;
    this.binaryEncoding = ctx.getRuntime().getEncodingService().getAscii8bitEncoding();
    return this;
  }

  private void ensureRemainingCapacity(int c) {
    if (!writeMode) {
      buffer.compact();
      writeMode = true;
    }
    if (buffer.remaining() < c) {
      int newLength = Math.max(buffer.capacity() + (buffer.capacity() >> 1), buffer.capacity() + c);
      newLength += CACHE_LINE_SIZE - ((ARRAY_HEADER_SIZE + newLength) % CACHE_LINE_SIZE);
      buffer = ByteBuffer.allocate(newLength).put(buffer.array(), 0, buffer.position());
    }
  }

  private void ensureReadMode() {
    if (writeMode) {
      buffer.flip();
      writeMode = false;
    }
  }

  private int rawSize() {
    if (writeMode) {
      return buffer.position();
    } else {
      return buffer.limit() - buffer.position();
    }
  }

  @JRubyMethod(name = "clear")
  public IRubyObject clear(ThreadContext ctx) {
    if (!writeMode) {
      buffer.compact();
      writeMode = true;
    }
    buffer.clear();
    return ctx.getRuntime().getNil();
  }

  @JRubyMethod(name = "size")
  public IRubyObject size(ThreadContext ctx) {
    return ctx.getRuntime().newFixnum(rawSize());
  }

  @JRubyMethod(name = "empty?")
  public IRubyObject isEmpty(ThreadContext ctx) {
    return rawSize() == 0 ? ctx.getRuntime().getTrue() : ctx.getRuntime().getFalse();
  }

  private IRubyObject bufferWrite(ThreadContext ctx, IRubyObject str) {
    ByteList bytes = str.asString().getByteList();
    int length = bytes.length();
    ensureRemainingCapacity(length);
    buffer.put(bytes.unsafeBytes(), bytes.begin(), length);
    return ctx.getRuntime().newFixnum(length);

  }

  @JRubyMethod(name = "write", alias = {"<<"})
  public IRubyObject write(ThreadContext ctx, IRubyObject str) {
    if (io == null) {
      return bufferWrite(ctx, str);
    } else {
      return io.callMethod(ctx, "write", str);
    }
  }

  private void feed(ThreadContext ctx) {
    if (io != null) {
      bufferWrite(ctx, io.callMethod(ctx, "read"));
    }
  }

  private IRubyObject readCommon(ThreadContext ctx, IRubyObject[] args, boolean raiseOnUnderflow) {
    feed(ctx);
    int length = rawSize();
    if (args != null && args.length == 1) {
      length = (int) args[0].convertToInteger().getLongValue();
    }
    if (raiseOnUnderflow && rawSize() < length) {
      throw ctx.getRuntime().newEOFError();
    }
    int readLength = Math.min(length, rawSize());
    if (readLength == 0 && length > 0) {
      return ctx.getRuntime().getNil();
    } else if (readLength == 0) {
      return ctx.getRuntime().newString();
    } else {
      ensureReadMode();
      byte[] bytes = new byte[readLength];
      buffer.get(bytes);
      ByteList byteList = new ByteList(bytes, binaryEncoding);
      return ctx.getRuntime().newString(byteList);
    }
  }

  @JRubyMethod(name = "read", optional = 1)
  public IRubyObject read(ThreadContext ctx, IRubyObject[] args) {
    return readCommon(ctx, args, false);
  }

  @JRubyMethod(name = "read_all", optional = 1)
  public IRubyObject readAll(ThreadContext ctx, IRubyObject[] args) {
    return readCommon(ctx, args, true);
  }

  private IRubyObject skipCommon(ThreadContext ctx, IRubyObject _length, boolean raiseOnUnderflow) {
    feed(ctx);
    int length = (int) _length.convertToInteger().getLongValue();
    if (raiseOnUnderflow && rawSize() < length) {
      throw ctx.getRuntime().newEOFError();
    }
    ensureReadMode();
    int skipLength = Math.min(length, rawSize());
    buffer.position(buffer.position() + skipLength);
    return ctx.getRuntime().newFixnum(skipLength);
  }

  @JRubyMethod(name = "skip")
  public IRubyObject skip(ThreadContext ctx, IRubyObject length) {
    return skipCommon(ctx, length, false);
  }

  @JRubyMethod(name = "skip_all")
  public IRubyObject skipAll(ThreadContext ctx, IRubyObject length) {
    return skipCommon(ctx, length, true);
  }

  @JRubyMethod(name = "to_s", alias = {"to_str"})
  public IRubyObject toS(ThreadContext ctx) {
    ensureReadMode();
    int length = buffer.limit() - buffer.position();
    ByteList str = new ByteList(buffer.array(), buffer.position(), length, binaryEncoding, true);
    return ctx.getRuntime().newString(str);
  }

  @JRubyMethod(name = "to_a")
  public IRubyObject toA(ThreadContext ctx) {
    return ctx.getRuntime().newArray(toS(ctx));
  }

  @JRubyMethod(name = "io")
  public IRubyObject getIo(ThreadContext ctx) {
    return io == null ? ctx.getRuntime().getNil() : io;
  }

  @JRubyMethod(name = "flush")
  public IRubyObject flush(ThreadContext ctx) {
    if (io == null) {
      return ctx.getRuntime().getNil();
    } else {
      return io.callMethod(ctx, "flush");
    }
  }

  @JRubyMethod(name = "close")
  public IRubyObject close(ThreadContext ctx) {
    if (io == null) {
      return ctx.getRuntime().getNil();
    } else {
      return io.callMethod(ctx, "close");
    }
  }

  @JRubyMethod(name = "write_to")
  public IRubyObject writeTo(ThreadContext ctx, IRubyObject io) {
    return io.callMethod(ctx, "write", readCommon(ctx, null, false));
  }
}
