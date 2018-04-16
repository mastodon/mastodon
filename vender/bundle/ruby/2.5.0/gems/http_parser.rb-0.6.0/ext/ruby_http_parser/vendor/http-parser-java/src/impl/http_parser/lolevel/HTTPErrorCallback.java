package http_parser.lolevel;

import java.nio.ByteBuffer;

public interface HTTPErrorCallback {
	public void cb (HTTPParser parser, String mes, ByteBuffer buf, int initial_position);
}
