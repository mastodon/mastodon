package org.msgpack.jruby;


import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.nio.BufferUnderflowException;
import java.util.Iterator;
import java.util.Arrays;

import org.jruby.Ruby;
import org.jruby.RubyObject;
import org.jruby.RubyClass;
import org.jruby.RubyBignum;
import org.jruby.RubyString;
import org.jruby.RubyArray;
import org.jruby.RubyHash;
import org.jruby.exceptions.RaiseException;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.util.ByteList;

import org.jcodings.Encoding;
import org.jcodings.specific.UTF8Encoding;

import static org.msgpack.jruby.Types.*;


public class Decoder implements Iterator<IRubyObject> {
  private final Ruby runtime;
  private final Encoding binaryEncoding;
  private final Encoding utf8Encoding;
  private final RubyClass unpackErrorClass;
  private final RubyClass underflowErrorClass;
  private final RubyClass malformedFormatErrorClass;
  private final RubyClass stackErrorClass;
  private final RubyClass unexpectedTypeErrorClass;
  private final RubyClass unknownExtTypeErrorClass;

  private ExtensionRegistry registry;
  private ByteBuffer buffer;
  private boolean symbolizeKeys;
  private boolean allowUnknownExt;

  public Decoder(Ruby runtime) {
    this(runtime, null, new byte[] {}, 0, 0, false, false);
  }

  public Decoder(Ruby runtime, ExtensionRegistry registry) {
    this(runtime, registry, new byte[] {}, 0, 0, false, false);
  }

  public Decoder(Ruby runtime, byte[] bytes) {
    this(runtime, null, bytes, 0, bytes.length, false, false);
  }

  public Decoder(Ruby runtime, ExtensionRegistry registry, byte[] bytes) {
    this(runtime, registry, bytes, 0, bytes.length, false, false);
  }

  public Decoder(Ruby runtime, ExtensionRegistry registry, byte[] bytes, boolean symbolizeKeys, boolean allowUnknownExt) {
    this(runtime, registry, bytes, 0, bytes.length, symbolizeKeys, allowUnknownExt);
  }

  public Decoder(Ruby runtime, ExtensionRegistry registry, byte[] bytes, int offset, int length) {
    this(runtime, registry, bytes, offset, length, false, false);
  }

  public Decoder(Ruby runtime, ExtensionRegistry registry, byte[] bytes, int offset, int length, boolean symbolizeKeys, boolean allowUnknownExt) {
    this.runtime = runtime;
    this.registry = registry;
    this.symbolizeKeys = symbolizeKeys;
    this.allowUnknownExt = allowUnknownExt;
    this.binaryEncoding = runtime.getEncodingService().getAscii8bitEncoding();
    this.utf8Encoding = UTF8Encoding.INSTANCE;
    this.unpackErrorClass = runtime.getModule("MessagePack").getClass("UnpackError");
    this.underflowErrorClass = runtime.getModule("MessagePack").getClass("UnderflowError");
    this.malformedFormatErrorClass = runtime.getModule("MessagePack").getClass("MalformedFormatError");
    this.stackErrorClass = runtime.getModule("MessagePack").getClass("StackError");
    this.unexpectedTypeErrorClass = runtime.getModule("MessagePack").getClass("UnexpectedTypeError");
    this.unknownExtTypeErrorClass = runtime.getModule("MessagePack").getClass("UnknownExtTypeError");
    this.symbolizeKeys = symbolizeKeys;
    this.allowUnknownExt = allowUnknownExt;
    feed(bytes, offset, length);
  }

  public void feed(byte[] bytes) {
    feed(bytes, 0, bytes.length);
  }

  public void feed(byte[] bytes, int offset, int length) {
    if (buffer == null) {
      buffer = ByteBuffer.wrap(bytes, offset, length);
    } else {
      ByteBuffer newBuffer = ByteBuffer.allocate(buffer.remaining() + length);
      newBuffer.put(buffer);
      newBuffer.put(bytes, offset, length);
      newBuffer.flip();
      buffer = newBuffer;
    }
  }

  public void reset() {
    buffer = null;
  }

  public int offset() {
    return buffer.position();
  }

  private IRubyObject consumeUnsignedLong() {
    long value = buffer.getLong();
    if (value < 0) {
      return RubyBignum.newBignum(runtime, BigInteger.valueOf(value & ((1L<<63)-1)).setBit(63));
    } else {
      return runtime.newFixnum(value);
    }
  }

  private IRubyObject consumeString(int size, Encoding encoding) {
    byte[] bytes = readBytes(size);
    ByteList byteList = new ByteList(bytes, encoding);
    return runtime.newString(byteList);
  }

  private IRubyObject consumeArray(int size) {
    IRubyObject[] elements = new IRubyObject[size];
    for (int i = 0; i < size; i++) {
      elements[i] = next();
    }
    return runtime.newArray(elements);
  }

  private IRubyObject consumeHash(int size) {
    RubyHash hash = RubyHash.newHash(runtime);
    for (int i = 0; i < size; i++) {
      IRubyObject key = next();
      if (this.symbolizeKeys && key instanceof RubyString) {
          key = ((RubyString) key).intern();
      }
      hash.fastASet(key, next());
    }
    return hash;
  }

  private IRubyObject consumeExtension(int size) {
    int type = buffer.get();
    byte[] payload = readBytes(size);

    if (registry != null) {
      IRubyObject proc = registry.lookupUnpackerByTypeId(type);
      if (proc != null) {
        ByteList byteList = new ByteList(payload, runtime.getEncodingService().getAscii8bitEncoding());
        return proc.callMethod(runtime.getCurrentContext(), "call", runtime.newString(byteList));
      }
    }

    if (this.allowUnknownExt) {
      return ExtensionValue.newExtensionValue(runtime, type, payload);
    }

    throw runtime.newRaiseException(unknownExtTypeErrorClass, "unexpected extension type");
  }

  private byte[] readBytes(int size) {
    byte[] payload = new byte[size];
    buffer.get(payload);
    return payload;
  }

  @Override
  public void remove() {
    throw new UnsupportedOperationException();
  }

  @Override
  public boolean hasNext() {
    return buffer.remaining() > 0;
  }

  public IRubyObject read_array_header() {
    int position = buffer.position();
    try {
      byte b = buffer.get();
      if ((b & 0xf0) == 0x90) {
        return runtime.newFixnum(b & 0x0f);
      } else if (b == ARY16) {
        return runtime.newFixnum(buffer.getShort() & 0xffff);
      } else if (b == ARY32) {
        return runtime.newFixnum(buffer.getInt());
      }
      throw runtime.newRaiseException(unexpectedTypeErrorClass, "unexpected type");
    } catch (RaiseException re) {
      buffer.position(position);
      throw re;
    } catch (BufferUnderflowException bue) {
      buffer.position(position);
      throw runtime.newRaiseException(underflowErrorClass, "Not enough bytes available");
    }
  }

  public IRubyObject read_map_header() {
    int position = buffer.position();
    try {
      byte b = buffer.get();
      if ((b & 0xf0) == 0x80) {
        return runtime.newFixnum(b & 0x0f);
      } else if (b == MAP16) {
        return runtime.newFixnum(buffer.getShort() & 0xffff);
      } else if (b == MAP32) {
        return runtime.newFixnum(buffer.getInt());
      }
      throw runtime.newRaiseException(unexpectedTypeErrorClass, "unexpected type");
    } catch (RaiseException re) {
      buffer.position(position);
      throw re;
    } catch (BufferUnderflowException bue) {
      buffer.position(position);
      throw runtime.newRaiseException(underflowErrorClass, "Not enough bytes available");
    }
  }

  @Override
  public IRubyObject next() {
    int position = buffer.position();
    try {
      byte b = buffer.get();
      outer: switch ((b >> 4) & 0xf) {
      case 0x8: return consumeHash(b & 0x0f);
      case 0x9: return consumeArray(b & 0x0f);
      case 0xa:
      case 0xb: return consumeString(b & 0x1f, utf8Encoding);
      case 0xc:
        switch (b) {
        case NIL:      return runtime.getNil();
        case FALSE:    return runtime.getFalse();
        case TRUE:     return runtime.getTrue();
        case BIN8:     return consumeString(buffer.get() & 0xff, binaryEncoding);
        case BIN16:    return consumeString(buffer.getShort() & 0xffff, binaryEncoding);
        case BIN32:    return consumeString(buffer.getInt(), binaryEncoding);
        case VAREXT8:  return consumeExtension(buffer.get() & 0xff);
        case VAREXT16: return consumeExtension(buffer.getShort() & 0xffff);
        case VAREXT32: return consumeExtension(buffer.getInt());
        case FLOAT32:  return runtime.newFloat(buffer.getFloat());
        case FLOAT64:  return runtime.newFloat(buffer.getDouble());
        case UINT8:    return runtime.newFixnum(buffer.get() & 0xffL);
        case UINT16:   return runtime.newFixnum(buffer.getShort() & 0xffffL);
        case UINT32:   return runtime.newFixnum(buffer.getInt() & 0xffffffffL);
        case UINT64:   return consumeUnsignedLong();
        default: break outer;
        }
      case 0xd:
        switch (b) {
        case INT8:     return runtime.newFixnum(buffer.get());
        case INT16:    return runtime.newFixnum(buffer.getShort());
        case INT32:    return runtime.newFixnum(buffer.getInt());
        case INT64:    return runtime.newFixnum(buffer.getLong());
        case FIXEXT1:  return consumeExtension(1);
        case FIXEXT2:  return consumeExtension(2);
        case FIXEXT4:  return consumeExtension(4);
        case FIXEXT8:  return consumeExtension(8);
        case FIXEXT16: return consumeExtension(16);
        case STR8:     return consumeString(buffer.get() & 0xff, utf8Encoding);
        case STR16:    return consumeString(buffer.getShort() & 0xffff, utf8Encoding);
        case STR32:    return consumeString(buffer.getInt(), utf8Encoding);
        case ARY16:    return consumeArray(buffer.getShort() & 0xffff);
        case ARY32:    return consumeArray(buffer.getInt());
        case MAP16:    return consumeHash(buffer.getShort() & 0xffff);
        case MAP32:    return consumeHash(buffer.getInt());
        default: break outer;
        }
      case 0xe:
      case 0xf: return runtime.newFixnum((0x1f & b) - 0x20);
      default: return runtime.newFixnum(b);
      }
      buffer.position(position);
      throw runtime.newRaiseException(malformedFormatErrorClass, "Illegal byte sequence");
    } catch (RaiseException re) {
      buffer.position(position);
      throw re;
    } catch (BufferUnderflowException bue) {
      buffer.position(position);
      throw runtime.newRaiseException(underflowErrorClass, "Not enough bytes available");
    }
  }
}
