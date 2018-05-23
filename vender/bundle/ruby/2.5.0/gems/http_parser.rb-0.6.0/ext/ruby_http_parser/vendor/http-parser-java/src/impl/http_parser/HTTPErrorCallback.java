package http_parser;


import java.nio.ByteBuffer;

public abstract class HTTPErrorCallback implements http_parser.lolevel.HTTPErrorCallback{
	public void cb (http_parser.lolevel.HTTPParser parser, String mes, ByteBuffer buf, int initial_position) {
	  this.cb((HTTPParser)parser, Util.error(mes, buf, initial_position));
	}

  public abstract void cb(HTTPParser parser, String error); 
}
