package http_parser;

public class FieldData {
  public int off;
  public int len;

  public FieldData(){}

  public FieldData(int off, int len){
    this.off = off;
    this.len = len;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    FieldData fieldData = (FieldData) o;

    if (len != fieldData.len) return false;
    if (off != fieldData.off) return false;

    return true;
  }

  @Override
  public int hashCode() {
    int result = off;
    result = 31 * result + len;
    return result;
  }

  @Override
  public String toString() {
    return "FieldData{" +
        "off=" + off +
        ", len=" + len +
        '}';
  }
}
