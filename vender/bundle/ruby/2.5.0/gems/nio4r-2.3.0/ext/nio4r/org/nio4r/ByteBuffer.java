package org.nio4r;

import java.io.IOException;
import java.nio.channels.Channel;
import java.nio.channels.SelectableChannel;
import java.nio.channels.ReadableByteChannel;
import java.nio.channels.WritableByteChannel;
import java.nio.BufferOverflowException;
import java.nio.BufferUnderflowException;
import java.nio.InvalidMarkException;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyIO;
import org.jruby.RubyNumeric;
import org.jruby.RubyObject;
import org.jruby.RubyString;
import org.jruby.anno.JRubyMethod;
import org.jruby.exceptions.RaiseException;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.Block;

/*
created by Upekshej
 */
public class ByteBuffer extends RubyObject {
    private java.nio.ByteBuffer byteBuffer;

    public static RaiseException newOverflowError(ThreadContext context, String message) {
        RubyClass klass = context.runtime.getModule("NIO").getClass("ByteBuffer").getClass("OverflowError");
        return context.runtime.newRaiseException(klass, message);
    }

    public static RaiseException newUnderflowError(ThreadContext context, String message) {
        RubyClass klass = context.runtime.getModule("NIO").getClass("ByteBuffer").getClass("UnderflowError");
        return context.runtime.newRaiseException(klass, message);
    }

    public static RaiseException newMarkUnsetError(ThreadContext context, String message) {
        RubyClass klass = context.runtime.getModule("NIO").getClass("ByteBuffer").getClass("MarkUnsetError");
        return context.runtime.newRaiseException(klass, message);
    }

    public ByteBuffer(final Ruby ruby, RubyClass rubyClass) {
        super(ruby, rubyClass);
    }

    @JRubyMethod
    public IRubyObject initialize(ThreadContext context, IRubyObject capacity) {
        this.byteBuffer = java.nio.ByteBuffer.allocate(RubyNumeric.num2int(capacity));
        return this;
    }

    @JRubyMethod
    public IRubyObject clear(ThreadContext context) {
        this.byteBuffer.clear();
        return this;
    }

    @JRubyMethod(name = "position")
    public IRubyObject getPosition(ThreadContext context) {
        return context.getRuntime().newFixnum(this.byteBuffer.position());
    }

    @JRubyMethod(name = "position=")
    public IRubyObject setPosition(ThreadContext context, IRubyObject newPosition) {
        int pos = RubyNumeric.num2int(newPosition);

        if(pos < 0) {
            throw context.runtime.newArgumentError("negative position given");
        }

        if(pos > this.byteBuffer.limit()) {
            throw context.runtime.newArgumentError("specified position exceeds limit");
        }

        try {
            this.byteBuffer.position(pos);
            return newPosition;
        } catch(IllegalArgumentException e) {
            throw context.runtime.newArgumentError(e.getLocalizedMessage());
        }
    }

    @JRubyMethod(name = "limit")
    public IRubyObject getLimit(ThreadContext context) {
        return context.getRuntime().newFixnum(this.byteBuffer.limit());
    }

    @JRubyMethod(name = "limit=")
    public IRubyObject setLimit(ThreadContext context, IRubyObject newLimit) {
        int lim = RubyNumeric.num2int(newLimit);

        if(lim < 0) {
            throw context.runtime.newArgumentError("negative limit given");
        }

        if(lim > this.byteBuffer.capacity()) {
            throw context.runtime.newArgumentError("specified limit exceeds capacity");
        }

        try {
            this.byteBuffer.limit(lim);
            return newLimit;
        } catch(IllegalArgumentException e) {
            throw context.runtime.newArgumentError(e.getLocalizedMessage());
        }
    }

    @JRubyMethod(name = {"capacity", "size"})
    public IRubyObject capacity(ThreadContext context) {
        return context.getRuntime().newFixnum(this.byteBuffer.capacity());
    }

    @JRubyMethod
    public IRubyObject remaining(ThreadContext context) {
        return context.getRuntime().newFixnum(this.byteBuffer.remaining());
    }

    @JRubyMethod(name = "full?")
    public IRubyObject isFull(ThreadContext context) {
        if (this.byteBuffer.hasRemaining()) {
            return context.getRuntime().getFalse();
        } else {
            return context.getRuntime().getTrue();
        }
    }

    @JRubyMethod
    public IRubyObject get(ThreadContext context) {
        return this.get(context, context.getRuntime().newFixnum(this.byteBuffer.remaining()));
    }

    @JRubyMethod
    public IRubyObject get(ThreadContext context, IRubyObject length) {
        int len = RubyNumeric.num2int(length);
        byte[] bytes = new byte[len];

        try {
            this.byteBuffer.get(bytes);
        } catch(BufferUnderflowException e) {
            throw ByteBuffer.newUnderflowError(context, "not enough data in buffer");
        }

        return RubyString.newString(context.getRuntime(), bytes);
    }

    @JRubyMethod(name = "[]")
    public IRubyObject fetch(ThreadContext context, IRubyObject index) {
        int i = RubyNumeric.num2int(index);

        if(i < 0) {
            throw context.runtime.newArgumentError("negative index given");
        }

        if(i >= this.byteBuffer.limit()) {
            throw context.runtime.newArgumentError("index exceeds limit");
        }

        return context.getRuntime().newFixnum(this.byteBuffer.get(i));
    }

    @JRubyMethod(name = "<<")
    public IRubyObject put(ThreadContext context, IRubyObject str) {
        try {
            this.byteBuffer.put(str.convertToString().getByteList().bytes());
        } catch(BufferOverflowException e) {
            throw ByteBuffer.newOverflowError(context, "buffer is full");
        }

        return this;
    }

    @JRubyMethod(name = "read_from")
    public IRubyObject readFrom(ThreadContext context, IRubyObject io) {
        Ruby runtime = context.runtime;
        Channel channel = RubyIO.convertToIO(context, io).getChannel();

        if(!this.byteBuffer.hasRemaining()) {
            throw ByteBuffer.newOverflowError(context, "buffer is full");
        }

        if(!(channel instanceof ReadableByteChannel) || !(channel instanceof SelectableChannel)) {
            throw runtime.newArgumentError("unsupported IO object: " + io.getType().toString());
        }

        try {
            ((SelectableChannel)channel).configureBlocking(false);
        } catch(IOException ie) {
            throw runtime.newIOError(ie.getLocalizedMessage());
        }

        try {
            int bytesRead = ((ReadableByteChannel)channel).read(this.byteBuffer);

            if(bytesRead >= 0) {
                return runtime.newFixnum(bytesRead);
            } else {
                throw runtime.newEOFError();
            }
        } catch(IOException ie) {
            throw runtime.newIOError(ie.getLocalizedMessage());
        }
    }

    @JRubyMethod(name = "write_to")
    public IRubyObject writeTo(ThreadContext context, IRubyObject io) {
        Ruby runtime = context.runtime;
        Channel channel = RubyIO.convertToIO(context, io).getChannel();

        if(!this.byteBuffer.hasRemaining()) {
            throw ByteBuffer.newUnderflowError(context, "not enough data in buffer");
        }

        if(!(channel instanceof WritableByteChannel) || !(channel instanceof SelectableChannel)) {
            throw runtime.newArgumentError("unsupported IO object: " + io.getType().toString());
        }

        try {
            ((SelectableChannel)channel).configureBlocking(false);
        } catch(IOException ie) {
            throw runtime.newIOError(ie.getLocalizedMessage());
        }

        try {
            int bytesWritten = ((WritableByteChannel)channel).write(this.byteBuffer);

            if(bytesWritten >= 0) {
                return runtime.newFixnum(bytesWritten);
            } else {
                throw runtime.newEOFError();
            }
        } catch(IOException ie) {
            throw runtime.newIOError(ie.getLocalizedMessage());
        }
    }

    @JRubyMethod
    public IRubyObject flip(ThreadContext context) {
        this.byteBuffer.flip();
        return this;
    }

    @JRubyMethod
    public IRubyObject rewind(ThreadContext context) {
        this.byteBuffer.rewind();
        return this;
    }

    @JRubyMethod
    public IRubyObject mark(ThreadContext context) {
        this.byteBuffer.mark();
        return this;
    }

    @JRubyMethod
    public IRubyObject reset(ThreadContext context) {
        try {
            this.byteBuffer.reset();
            return this;
        } catch(InvalidMarkException ie) {
            throw ByteBuffer.newMarkUnsetError(context, "mark has not been set");
        }
    }

    @JRubyMethod
    public IRubyObject compact(ThreadContext context) {
        this.byteBuffer.compact();
        return this;
    }

    @JRubyMethod
    public IRubyObject each(ThreadContext context, Block block) {
        for(int i = 0; i < this.byteBuffer.limit(); i++) {
            block.call(context, context.getRuntime().newFixnum(this.byteBuffer.get(i)));
        }

        return this;
    }

    @JRubyMethod
    public IRubyObject inspect(ThreadContext context) {
        return context.runtime.newString(String.format(
            "#<%s:0x%x @position=%d @limit=%d @capacity=%d>",
            this.getType().toString(),
            System.identityHashCode(this),
            this.byteBuffer.position(),
            this.byteBuffer.limit(),
            this.byteBuffer.capacity()
        ));
    }
}
