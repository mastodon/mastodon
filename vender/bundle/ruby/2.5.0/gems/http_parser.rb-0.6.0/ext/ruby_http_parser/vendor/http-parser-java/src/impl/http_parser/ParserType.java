package http_parser;

public enum ParserType {
HTTP_REQUEST, HTTP_RESPONSE, HTTP_BOTH;

	public static ParserType parse(String s) {
		     if ("HTTP_REQUEST".equalsIgnoreCase(s))  { return HTTP_REQUEST; }
		else if ("HTTP_RESPONSE".equalsIgnoreCase(s)) { return HTTP_RESPONSE; }
		else if ("HTTP_BOTH".equalsIgnoreCase(s))     { return HTTP_BOTH; }
		else                                          { return null; }
	}
}

