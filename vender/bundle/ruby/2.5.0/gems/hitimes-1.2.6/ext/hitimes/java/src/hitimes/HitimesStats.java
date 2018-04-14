package hitimes;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyObject;

import org.jruby.RubyNumeric;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.ObjectAllocator;

import org.jruby.anno.JRubyMethod;
import org.jruby.anno.JRubyClass;

@JRubyClass( name = "Hitimes::Stats" )
public class HitimesStats extends RubyObject {

    private double min   = 0.0;
    private double max   = 0.0;
    private double sum   = 0.0;
    private double sumsq = 0.0;
    private long   count = 0;

    public static final ObjectAllocator ALLOCATOR = new ObjectAllocator() {
        public IRubyObject allocate(Ruby runtime, RubyClass klass) {
            return new HitimesStats( runtime, klass );
        }
    };

    public HitimesStats( Ruby runtime, RubyClass klass ) {
        super( runtime, klass );
    }

    @JRubyMethod( name = "update", required = 1, argTypes = RubyNumeric.class )
    public IRubyObject update( IRubyObject val ) {
        double v = RubyNumeric.num2dbl( val );

        if ( 0 == this.count ) {
            this.min = this.max = v;
        } else {
            this.min = ( v < this.min ) ? v : this.min;
            this.max = ( v > this.max ) ? v : this.max;
        }

        this.count += 1;
        this.sum   += v;
        this.sumsq += (v * v);

        return val;
    }

    @JRubyMethod( name = "mean" )
    public IRubyObject mean() {
        double mean = 0.0;

        if ( this.count > 0 ) {
            mean = this.sum / this.count;
        }

        return getRuntime().newFloat( mean );
    }


    @JRubyMethod( name = "rate" )
    public IRubyObject rate() {
        double rate = 0.0;

        if ( this.sum > 0.0 ) {
            rate = this.count / this.sum ;
        }

        return getRuntime().newFloat( rate );
    }

    @JRubyMethod( name = "stddev" )
    public IRubyObject stddev() {
        double stddev = 0.0;

        if ( this.count > 1 ) {
            double sq_sum = this.sum * this.sum;
            stddev = Math.sqrt( ( this.sumsq - ( sq_sum / this.count ) ) / ( this.count - 1 ) );
        }
        return getRuntime().newFloat( stddev );
    }


    @JRubyMethod( name = "min" )
    public IRubyObject min() {
        return getRuntime().newFloat( this.min );
    }

    @JRubyMethod( name = "max" )
    public IRubyObject max() {
        return getRuntime().newFloat( this.max );
    }

    @JRubyMethod( name = "sum" )
    public IRubyObject sum() {
        return getRuntime().newFloat( this.sum );
    }

    @JRubyMethod( name = "sumsq" )
    public IRubyObject sumsq() {
        return getRuntime().newFloat( this.sumsq );
    }

    @JRubyMethod( name = "count" )
    public IRubyObject count() {
        return getRuntime().newFixnum( this.count );
    }
}


