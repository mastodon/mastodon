require 'time'
require 'rack/utils'
require 'rack/mime'

module Rack
  # Rack::Directory serves entries below the +root+ given, according to the
  # path info of the Rack request. If a directory is found, the file's contents
  # will be presented in an html based index. If a file is found, the env will
  # be passed to the specified +app+.
  #
  # If +app+ is not specified, a Rack::File of the same +root+ will be used.

  class Directory
    DIR_FILE = "<tr><td class='name'><a href='%s'>%s</a></td><td class='size'>%s</td><td class='type'>%s</td><td class='mtime'>%s</td></tr>"
    DIR_PAGE = <<-PAGE
<html><head>
  <title>%s</title>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <style type='text/css'>
table { width:100%%; }
.name { text-align:left; }
.size, .mtime { text-align:right; }
.type { width:11em; }
.mtime { width:15em; }
  </style>
</head><body>
<h1>%s</h1>
<hr />
<table>
  <tr>
    <th class='name'>Name</th>
    <th class='size'>Size</th>
    <th class='type'>Type</th>
    <th class='mtime'>Last Modified</th>
  </tr>
%s
</table>
<hr />
</body></html>
    PAGE

    class DirectoryBody < Struct.new(:root, :path, :files)
      def each
        show_path = Rack::Utils.escape_html(path.sub(/^#{root}/,''))
        listings = files.map{|f| DIR_FILE % DIR_FILE_escape(*f) }*"\n"
        page  = DIR_PAGE % [ show_path, show_path , listings ]
        page.each_line{|l| yield l }
      end

      private
      # Assumes url is already escaped.
      def DIR_FILE_escape url, *html
        [url, *html.map { |e| Utils.escape_html(e) }]
      end
    end

    attr_reader :root, :path

    def initialize(root, app=nil)
      @root = ::File.expand_path(root)
      @app = app || Rack::File.new(@root)
      @head = Rack::Head.new(lambda { |env| get env })
    end

    def call(env)
      # strip body if this is a HEAD call
      @head.call env
    end

    def get(env)
      script_name = env[SCRIPT_NAME]
      path_info = Utils.unescape_path(env[PATH_INFO])

      if bad_request = check_bad_request(path_info)
        bad_request
      elsif forbidden = check_forbidden(path_info)
        forbidden
      else
        path = ::File.join(@root, path_info)
        list_path(env, path, path_info, script_name)
      end
    end

    def check_bad_request(path_info)
      return if Utils.valid_path?(path_info)

      body = "Bad Request\n"
      size = body.bytesize
      return [400, {CONTENT_TYPE => "text/plain",
        CONTENT_LENGTH => size.to_s,
        "X-Cascade" => "pass"}, [body]]
    end

    def check_forbidden(path_info)
      return unless path_info.include? ".."

      body = "Forbidden\n"
      size = body.bytesize
      return [403, {CONTENT_TYPE => "text/plain",
        CONTENT_LENGTH => size.to_s,
        "X-Cascade" => "pass"}, [body]]
    end

    def list_directory(path_info, path, script_name)
      files = [['../','Parent Directory','','','']]
      glob = ::File.join(path, '*')

      url_head = (script_name.split('/') + path_info.split('/')).map do |part|
        Rack::Utils.escape_path part
      end

      Dir[glob].sort.each do |node|
        stat = stat(node)
        next unless stat
        basename = ::File.basename(node)
        ext = ::File.extname(node)

        url = ::File.join(*url_head + [Rack::Utils.escape_path(basename)])
        size = stat.size
        type = stat.directory? ? 'directory' : Mime.mime_type(ext)
        size = stat.directory? ? '-' : filesize_format(size)
        mtime = stat.mtime.httpdate
        url << '/'  if stat.directory?
        basename << '/'  if stat.directory?

        files << [ url, basename, size, type, mtime ]
      end

      return [ 200, { CONTENT_TYPE =>'text/html; charset=utf-8'}, DirectoryBody.new(@root, path, files) ]
    end

    def stat(node)
      ::File.stat(node)
    rescue Errno::ENOENT, Errno::ELOOP
      return nil
    end

    # TODO: add correct response if not readable, not sure if 404 is the best
    #       option
    def list_path(env, path, path_info, script_name)
      stat = ::File.stat(path)

      if stat.readable?
        return @app.call(env) if stat.file?
        return list_directory(path_info, path, script_name) if stat.directory?
      else
        raise Errno::ENOENT, 'No such file or directory'
      end

    rescue Errno::ENOENT, Errno::ELOOP
      return entity_not_found(path_info)
    end

    def entity_not_found(path_info)
      body = "Entity not found: #{path_info}\n"
      size = body.bytesize
      return [404, {CONTENT_TYPE => "text/plain",
        CONTENT_LENGTH => size.to_s,
        "X-Cascade" => "pass"}, [body]]
    end

    # Stolen from Ramaze

    FILESIZE_FORMAT = [
      ['%.1fT', 1 << 40],
      ['%.1fG', 1 << 30],
      ['%.1fM', 1 << 20],
      ['%.1fK', 1 << 10],
    ]

    def filesize_format(int)
      FILESIZE_FORMAT.each do |format, size|
        return format % (int.to_f / size) if int >= size
      end

      "#{int}B"
    end
  end
end
