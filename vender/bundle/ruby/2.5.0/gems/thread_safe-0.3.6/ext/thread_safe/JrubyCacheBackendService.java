package thread_safe;

import java.io.IOException;

import org.jruby.Ruby;
import org.jruby.ext.thread_safe.JRubyCacheBackendLibrary;
import org.jruby.runtime.load.BasicLibraryService;

// can't name this JRubyCacheBackendService or else JRuby doesn't pick this up
public class JrubyCacheBackendService implements BasicLibraryService {
    public boolean basicLoad(final Ruby runtime) throws IOException {
        new JRubyCacheBackendLibrary().load(runtime, false);
        return true;
    }
}
