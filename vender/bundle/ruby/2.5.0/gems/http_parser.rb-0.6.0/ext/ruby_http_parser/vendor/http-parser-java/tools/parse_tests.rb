



# name  : 200 trailing space on chunked body
# raw   : "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nTransfer-Encoding: chunked\r\n\r\n25  \r\nThis is the data in the first chunk\r\n\r\n1C\r\nand this is the second one\r\n\r\n0  \r\n\r\n"
# type  : HTTP_RESPONSE
# method: HTTP_DELETE
# status code :200
# request_path:
# request_url :
# fragment    :
# query_string:
# body        :"This is the data in the first chunk\r\nand this is the second one\r\n"
# body_size   :65
# header_0 :{ "Content-Type": "text/plain"}
# header_1 :{ "Transfer-Encoding": "chunked"}
# should_keep_alive         :1
# upgrade                   :0
# http_major                :1
# http_minor                :1


class ParserTest
	attr_accessor :name
	attr_accessor :raw
	attr_accessor :type
	attr_accessor :method
	attr_accessor :status_code
	attr_accessor :request_path
	attr_accessor :method
end

