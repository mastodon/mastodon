package org.msgpack.jruby;


public interface Types {
  public static final byte FIXSTR   = (byte) 0xa0; // This is actually not header byte, but prefix bit mask
  public static final byte NIL      = (byte) 0xc0;
  public static final byte FALSE    = (byte) 0xc2;
  public static final byte TRUE     = (byte) 0xc3;
  public static final byte BIN8     = (byte) 0xc4;
  public static final byte BIN16    = (byte) 0xc5;
  public static final byte BIN32    = (byte) 0xc6;
  public static final byte VAREXT8  = (byte) 0xc7;
  public static final byte VAREXT16 = (byte) 0xc8;
  public static final byte VAREXT32 = (byte) 0xc9;
  public static final byte FLOAT32  = (byte) 0xca;
  public static final byte FLOAT64  = (byte) 0xcb;
  public static final byte UINT8    = (byte) 0xcc;
  public static final byte UINT16   = (byte) 0xcd;
  public static final byte UINT32   = (byte) 0xce;
  public static final byte UINT64   = (byte) 0xcf;
  public static final byte INT8     = (byte) 0xd0;
  public static final byte INT16    = (byte) 0xd1;
  public static final byte INT32    = (byte) 0xd2;
  public static final byte INT64    = (byte) 0xd3;
  public static final byte FIXEXT1  = (byte) 0xd4;
  public static final byte FIXEXT2  = (byte) 0xd5;
  public static final byte FIXEXT4  = (byte) 0xd6;
  public static final byte FIXEXT8  = (byte) 0xd7;
  public static final byte FIXEXT16 = (byte) 0xd8;
  public static final byte STR8     = (byte) 0xd9;
  public static final byte STR16    = (byte) 0xda;
  public static final byte STR32    = (byte) 0xdb;
  public static final byte ARY16    = (byte) 0xdc;
  public static final byte ARY32    = (byte) 0xdd;
  public static final byte MAP16    = (byte) 0xde;
  public static final byte MAP32    = (byte) 0xdf;
}
