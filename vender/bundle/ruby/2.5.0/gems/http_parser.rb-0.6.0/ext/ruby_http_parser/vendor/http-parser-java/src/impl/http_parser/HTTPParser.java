package http_parser;

import java.nio.ByteBuffer;

public class HTTPParser extends http_parser.lolevel.HTTPParser {
  
  public HTTPParser() { super(); }
  public HTTPParser(ParserType type) { super(type); }

  public int getMajor() {
    return super.http_major;
  }

  public int getMinor() {
    return super.http_minor;
  }

  public int getStatusCode() {
    return super.status_code;
  }

  public HTTPMethod getHTTPMethod() {
    return super.method;
  }

  public boolean getUpgrade() {
    return super.upgrade;
  }
  
  public boolean shouldKeepAlive() {
    return super.http_should_keep_alive();
  }
  public void execute(ParserSettings settings, ByteBuffer data) {
   this.execute(settings.getLoLevelSettings(), data);
  }
} 
