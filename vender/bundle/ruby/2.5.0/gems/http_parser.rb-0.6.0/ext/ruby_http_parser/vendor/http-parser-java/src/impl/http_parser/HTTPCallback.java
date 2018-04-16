package http_parser;

public abstract class HTTPCallback implements http_parser.lolevel.HTTPCallback{
	public int cb (http_parser.lolevel.HTTPParser parser) {
	  return this.cb((HTTPParser)parser);
	}
	public abstract int cb (HTTPParser parser);
}
