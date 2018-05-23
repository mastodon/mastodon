package puma;

import java.io.IOException;
        
import org.jruby.Ruby;
import org.jruby.runtime.load.BasicLibraryService;

import org.jruby.puma.Http11;
import org.jruby.puma.MiniSSL;

public class PumaHttp11Service implements BasicLibraryService { 
    public boolean basicLoad(final Ruby runtime) throws IOException {
        Http11.createHttp11(runtime);
        MiniSSL.createMiniSSL(runtime);
        return true;
    }
}
