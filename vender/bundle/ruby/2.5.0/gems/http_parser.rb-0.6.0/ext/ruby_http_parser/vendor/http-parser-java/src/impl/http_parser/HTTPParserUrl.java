package http_parser;

import http_parser.lolevel.*;
import http_parser.lolevel.HTTPParser;

import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.util.Arrays;

/**
 */
public class HTTPParserUrl {

  public int field_set;
  public int port;

  public FieldData[] field_data = new FieldData[]{
    new FieldData(0,0),
    new FieldData(0,0),
    new FieldData(0,0),
    new FieldData(0,0),
    new FieldData(0,0),
    new FieldData(0,0)
  }; //UF_MAX

  public HTTPParserUrl(){}

  public HTTPParserUrl(int field_set, int port, FieldData[] field_data){
    this.field_set = field_set;
    this.port = port;
    this.field_data = field_data;
  }

  public String getFieldValue(HTTPParser.UrlFields field, ByteBuffer data) throws UnsupportedEncodingException {
    FieldData fd = this.field_data[field.getIndex()];
    if(fd.off == 0 & fd.len == 0) return "";
    byte[] dst = new byte[fd.len];
    int current_pos = data.position();
    data.position(fd.off);
    data.get(dst,0,fd.len);
    data.position(current_pos);
    String v = new String(dst, "UTF8");
    return v;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    HTTPParserUrl that = (HTTPParserUrl) o;

    if (field_set != that.field_set) return false;
    if (port != that.port) return false;
    if (!Arrays.equals(field_data, that.field_data)) return false;

    return true;
  }

  @Override
  public int hashCode() {
    int result = field_set;
    result = 31 * result + port;
    result = 31 * result + Arrays.hashCode(field_data);
    return result;
  }

  @Override
  public String toString() {
    return "HTTPParserUrl{" +
        "field_set=" + field_set +
        ", port=" + port +
        ", field_data=" + (field_data == null ? null : Arrays.asList(field_data)) +
        '}';
  }
}
