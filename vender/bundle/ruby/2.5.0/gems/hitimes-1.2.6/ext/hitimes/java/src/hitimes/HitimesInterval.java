package hitimes;

import org.jruby.runtime.builtin.IRubyObject;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyObject;

import org.jruby.runtime.Block;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.ThreadContext;

import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;

@JRubyClass( name = "Hitimes::Interval" )
public class HitimesInterval extends RubyObject {

    /* this is a double to force all division by the conversion factor
     * to cast to doubles
     */
    private static final double INSTANT_CONVERSION_FACTOR = 1000000000d;

    private static final long   INSTANT_NOT_SET  = Long.MIN_VALUE;
    private static final double DURATION_NOT_SET = Double.NaN;

    public static final ObjectAllocator ALLOCATOR = new ObjectAllocator() {
        public IRubyObject allocate(Ruby runtime, RubyClass klass) {
            return new HitimesInterval( runtime, klass );
        }
    };

    public HitimesInterval( Ruby runtime, RubyClass klass ) {
        super( runtime, klass );
    }

    public HitimesInterval( Ruby runtime, RubyClass klass, long start ) {
        super( runtime, klass );
        this.start_instant = start;
    }


    private long start_instant = INSTANT_NOT_SET;
    private long stop_instant  = INSTANT_NOT_SET;
    private double duration    = DURATION_NOT_SET;

    @JRubyMethod( name = "duration", alias = { "length", "to_f", "to_seconds" } )
    public IRubyObject duration() {

        /*
         * if start has not yet been called, then raise an exception.
         */
        if ( INSTANT_NOT_SET == this.start_instant ) {
            throw Hitimes.newHitimesError( getRuntime(), "Attempt to report a duration on an interval that has not started");
        }

        /*
         * if stop has not yet been called, then return the amount of time so far
         */
        if ( INSTANT_NOT_SET == this.stop_instant ) {
            double d = ( System.nanoTime() - this.start_instant ) / INSTANT_CONVERSION_FACTOR;
            return getRuntime().newFloat( d );
        }

        /*
         * if stop has been called, then calculate the duration and return
         */
        if ( DURATION_NOT_SET == this.duration ) {
            this.duration = (this.stop_instant - this.start_instant) / INSTANT_CONVERSION_FACTOR;
        }

        return getRuntime().newFloat( this.duration );

    }

    @JRubyMethod( name = "duration_so_far" )
    public IRubyObject duration_so_far() {
        IRubyObject rc = getRuntime().getFalse();

        if ( INSTANT_NOT_SET == this.start_instant ) {
            return rc;
        }

        if ( INSTANT_NOT_SET == this.stop_instant ) {
            double d = ( System.nanoTime() - this.start_instant ) / INSTANT_CONVERSION_FACTOR;
            return getRuntime().newFloat( d );
        }

        return rc;
    }

    @JRubyMethod( name = "started?" )
    public IRubyObject is_started() {
        if ( INSTANT_NOT_SET == this.start_instant ) {
            return getRuntime().getFalse();
        }
        return getRuntime().getTrue();
    }

    @JRubyMethod( name = "running?" )
    public IRubyObject is_running() {
        if ( ( INSTANT_NOT_SET != this.start_instant ) && ( INSTANT_NOT_SET == this.stop_instant ) ) {
            return getRuntime().getTrue();
        }
        return getRuntime().getFalse();
    }

    @JRubyMethod( name = "stopped?" )
    public IRubyObject is_stopped() {
        if ( INSTANT_NOT_SET == this.stop_instant ) {
            return getRuntime().getFalse();
        }
        return getRuntime().getTrue();
    }

    @JRubyMethod( name = "start_instant" )
    public IRubyObject start_instant() {
        return getRuntime().newFixnum( this.start_instant );
    }

    @JRubyMethod( name = "stop_instant" )
    public IRubyObject stop_instant() {
        return getRuntime().newFixnum( this.stop_instant );
    }

    @JRubyMethod( name = "start" )
    public IRubyObject start() {
        if ( INSTANT_NOT_SET == this.start_instant ) {
            this.start_instant = System.nanoTime();
            return getRuntime().getTrue();
        }
        return getRuntime().getFalse();
    }

    @JRubyMethod( name = "stop" )
    public IRubyObject stop() {
        if ( INSTANT_NOT_SET == this.start_instant ) {
            throw Hitimes.newHitimesError( getRuntime(), "Attempt to stop an interval that has not started" );
        }

        if ( INSTANT_NOT_SET == this.stop_instant ) {
            this.stop_instant = System.nanoTime();
            this.duration = (this.stop_instant - this.start_instant) / INSTANT_CONVERSION_FACTOR;
            return getRuntime().newFloat( this.duration );
        }

        return getRuntime().getFalse();
    }

    @JRubyMethod( name = "split" )
    public IRubyObject split() {
        this.stop();
        return new HitimesInterval( getRuntime(), Hitimes.hitimesIntervalClass, this.stop_instant );
    }

    @JRubyMethod( name = "now", module = true )
    public static IRubyObject now( IRubyObject self ) {
        return new HitimesInterval( self.getRuntime(), Hitimes.hitimesIntervalClass, System.nanoTime() );
    }

    @JRubyMethod( name = "measure", module = true, frame = true )
    public static IRubyObject measure( IRubyObject self, Block block ) {

        Ruby runtime = self.getRuntime();

        if ( block.isGiven() ) {
            IRubyObject       nil = runtime.getNil();
            ThreadContext context = runtime.getCurrentContext();

            HitimesInterval interval = new HitimesInterval( runtime, Hitimes.hitimesIntervalClass );

            interval.start();
            block.yield( context, nil );
            interval.stop();

            return interval.duration();
        } else {
            throw Hitimes.newHitimesError( runtime, "No block given to Interval.measure" );
        }
    }
}
