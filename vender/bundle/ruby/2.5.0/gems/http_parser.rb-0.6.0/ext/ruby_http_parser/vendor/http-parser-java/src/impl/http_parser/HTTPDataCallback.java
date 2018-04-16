package http_parser;

import java.nio.ByteBuffer;

public abstract class HTTPDataCallback implements  http_parser.lolevel.HTTPDataCallback{
	/*
		Very raw and extremly foolhardy! DANGER!
		The whole Buffer concept is difficult enough to grasp as it is,
		we pass in a buffer with an arbitrary position.

		The interesting data is located at position pos and is len 
		bytes long.
		
		The contract of this callback is that the buffer is
		returned in the state that it was passed in, so implementing
		this require good citizenship, you'll need to remember the current
		position, change the position to get at the data you're interested 
		in and then set the position back to how you found it...

		Therefore: there is an abstract implementation that implements
		cb as described above, and provides a new callback
		with signature @see cb(byte[], int, int)
	*/
	public int cb(http_parser.lolevel.HTTPParser p, ByteBuffer buf, int pos, int len) {
	  byte [] by = new byte[len];
    int saved = buf.position();
    buf.position(pos);
    buf.get(by);
    buf.position(saved);
    return cb((HTTPParser)p, by, 0, len);
	}

  public abstract int cb(HTTPParser p, byte[] by, int pos, int len);
}
