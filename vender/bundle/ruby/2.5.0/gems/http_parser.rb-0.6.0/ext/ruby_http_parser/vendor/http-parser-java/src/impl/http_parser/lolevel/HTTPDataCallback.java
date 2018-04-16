package http_parser.lolevel;

import java.nio.ByteBuffer;

public interface HTTPDataCallback {
	/*
		very raw and extremly foolhardy! DANGER!
		The whole Buffer concept is difficult enough to grasp as it is,
		we pass in a buffer with an arbitrary position.

		The interesting data is located at position pos and is len 
		bytes long.
		
		The contract of this callback is that the buffer is
		returned in the state that it was passed in, so implementing
		this require good citizenship, you'll need to remember the current
		position, change the position to get at the data you're interested 
		in and then set the position back to how you found it...

		//TODO: there should be an abstract implementation that implements
		cb as described above, marks it final an provides a new callback
		with signature cb(byte[], int, int)
	*/
	public int cb(HTTPParser p, ByteBuffer buf, int pos, int len);
}
