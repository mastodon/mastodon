package hitimes;

import java.lang.Math;
import java.lang.System;

import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyModule;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyException;
import org.jruby.RubyModule;
import org.jruby.RubyObject;

import org.jruby.exceptions.RaiseException;


/**
 * @author <a href="mailto:jeremy@hinegardner.org">Jeremy Hinegardner</a>
 */
@JRubyModule( name = "Hitimes" )
public class Hitimes {

    public static RubyClass hitimesIntervalClass;
    /**
     * Create the Hitimes module and add it to the Ruby runtime.
     */
    public static RubyModule createHitimes( Ruby runtime ) {
        RubyModule mHitimes = runtime.defineModule("Hitimes");

        RubyClass  cStandardError = runtime.getStandardError();
        RubyClass  cHitimesError  = mHitimes.defineClassUnder("Error", cStandardError, cStandardError.getAllocator());

        RubyClass  cHitimesStats  = mHitimes.defineClassUnder("Stats", runtime.getObject(), HitimesStats.ALLOCATOR );
        cHitimesStats.defineAnnotatedMethods( HitimesStats.class );

        RubyClass  cHitimesInterval  = mHitimes.defineClassUnder("Interval", runtime.getObject(), HitimesInterval.ALLOCATOR );
        Hitimes.hitimesIntervalClass = cHitimesInterval;
        cHitimesInterval.defineAnnotatedMethods( HitimesInterval.class );

        return mHitimes;
    }

    static RaiseException newHitimesError( Ruby runtime, String message ) {
        RubyClass errorClass = runtime.getModule("Hitimes").getClass( "Error" );
        return new RaiseException( RubyException.newException( runtime, errorClass, message ), true );
    }



    @JRubyClass( name = "Hitimes::Error", parent = "StandardError" )
    public static class Error {};

}
