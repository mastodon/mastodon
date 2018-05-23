import java.io.IOException;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.runtime.load.BasicLibraryService;

import org.ruby_http_parser.*;

public class RubyHttpParserService implements BasicLibraryService {
  public boolean basicLoad(final Ruby runtime) throws IOException {
    RubyModule mHTTP = runtime.defineModule("HTTP");
    RubyClass cParser = mHTTP.defineClassUnder("Parser", runtime.getObject(), RubyHttpParser.ALLOCATOR);
    cParser.defineAnnotatedMethods(RubyHttpParser.class);
    cParser.defineClassUnder("Error", runtime.getClass("IOError"),runtime.getClass("IOError").getAllocator());
    return true;
  }
}
