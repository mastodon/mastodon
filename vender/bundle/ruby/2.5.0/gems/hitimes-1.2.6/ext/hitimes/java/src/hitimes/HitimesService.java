package hitimes;

import java.io.IOException;

import org.jruby.Ruby;

import org.jruby.runtime.load.BasicLibraryService;

public class HitimesService implements BasicLibraryService {
    public boolean basicLoad( final Ruby runtime ) throws IOException {
        Hitimes.createHitimes( runtime );
        return true;
    }
}


