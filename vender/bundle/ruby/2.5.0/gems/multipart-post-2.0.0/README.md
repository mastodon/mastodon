## multipart-post

* http://github.com/nicksieger/multipart-post

![build status](https://travis-ci.org/nicksieger/multipart-post.png)

#### DESCRIPTION:

Adds a streamy multipart form post capability to Net::HTTP. Also
supports other methods besides POST.

#### FEATURES/PROBLEMS:

* Appears to actually work. A good feature to have.
* Encapsulates posting of file/binary parts and name/value parameter parts, similar to 
  most browsers' file upload forms.
* Provides an UploadIO helper class to prepare IO objects for inclusion in the params
  hash of the multipart post object.

#### SYNOPSIS:

    require 'net/http/post/multipart'

    url = URI.parse('http://www.example.com/upload')
    File.open("./image.jpg") do |jpg|
      req = Net::HTTP::Post::Multipart.new url.path,
        "file" => UploadIO.new(jpg, "image/jpeg", "image.jpg")
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.request(req)
      end
    end

To post multiple files or attachments, simply include multiple parameters with
UploadIO values:

    require 'net/http/post/multipart'

    url = URI.parse('http://www.example.com/upload')
    req = Net::HTTP::Post::Multipart.new url.path,
      "file1" => UploadIO.new(File.new("./image.jpg"), "image/jpeg", "image.jpg"),
      "file2" => UploadIO.new(File.new("./image2.jpg"), "image/jpeg", "image2.jpg")
    res = Net::HTTP.start(url.host, url.port) do |http|
      http.request(req)
    end

#### REQUIREMENTS:

None

#### INSTALL:

    gem install multipart-post

#### LICENSE:

(The MIT License)

Copyright (c) 2007-2013 Nick Sieger <nick@nicksieger.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
