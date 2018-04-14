package org.nio4r;

import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;
import java.io.IOException;
import java.nio.channels.Channel;
import java.nio.channels.SelectableChannel;
import java.nio.channels.SelectionKey;
import java.nio.channels.CancelledKeyException;

import org.jruby.Ruby;
import org.jruby.RubyArray;
import org.jruby.RubyClass;
import org.jruby.RubyIO;
import org.jruby.RubyNumeric;
import org.jruby.RubyObject;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.Block;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;

import org.nio4r.Monitor;

public class Selector extends RubyObject {
    private java.nio.channels.Selector selector;
    private HashMap<SelectableChannel,SelectionKey> cancelledKeys;
    private volatile boolean wakeupFired;

    public Selector(final Ruby ruby, RubyClass rubyClass) {
        super(ruby, rubyClass);
    }

    @JRubyMethod(meta = true)
    public static IRubyObject backends(ThreadContext context, IRubyObject self) {
        return context.runtime.newArray(context.runtime.newSymbol("java"));
    }

    @JRubyMethod
    public IRubyObject initialize(ThreadContext context) {
        initialize(context, context.runtime.newSymbol("java"));
        return context.nil;
    }

    @JRubyMethod
    public IRubyObject initialize(ThreadContext context, IRubyObject backend) {
        if(backend != context.runtime.newSymbol("java")) {
            throw context.runtime.newArgumentError(":java is the only supported backend");
        }

        this.cancelledKeys = new HashMap<SelectableChannel,SelectionKey>();
        this.wakeupFired = false;

        try {
            this.selector = java.nio.channels.Selector.open();
        } catch(IOException ie) {
            throw context.runtime.newIOError(ie.getLocalizedMessage());
        }

        return context.nil;
    }

    @JRubyMethod
    public IRubyObject backend(ThreadContext context) {
        return context.runtime.newSymbol("java");
    }

    @JRubyMethod
    public IRubyObject close(ThreadContext context) {
        try {
            this.selector.close();
        } catch(IOException ie) {
            throw context.runtime.newIOError(ie.getLocalizedMessage());
        }

        return context.nil;
    }

    @JRubyMethod(name = "closed?")
    public IRubyObject isClosed(ThreadContext context) {
        Ruby runtime = context.getRuntime();
        return this.selector.isOpen() ? runtime.getFalse() : runtime.getTrue();
    }

    @JRubyMethod(name = "empty?")
    public IRubyObject isEmpty(ThreadContext context) {
        Ruby runtime = context.getRuntime();
        return this.selector.keys().isEmpty() ? runtime.getTrue() : runtime.getFalse();
    }

    @JRubyMethod
    public IRubyObject register(ThreadContext context, IRubyObject io, IRubyObject interests) {
        Ruby runtime = context.getRuntime();
        Channel rawChannel = RubyIO.convertToIO(context, io).getChannel();

        if(!this.selector.isOpen()) {
            throw context.getRuntime().newIOError("selector is closed");
        }

        if(!(rawChannel instanceof SelectableChannel)) {
            throw runtime.newArgumentError("not a selectable IO object");
        }

        SelectableChannel channel = (SelectableChannel)rawChannel;

        try {
            channel.configureBlocking(false);
        } catch(IOException ie) {
            throw runtime.newIOError(ie.getLocalizedMessage());
        }

        int interestOps = Nio4r.symbolToInterestOps(runtime, channel, interests);
        SelectionKey key;

        key = this.cancelledKeys.remove(channel);

        if(key != null) {
            key.interestOps(interestOps);
        } else {
            try {
                key = channel.register(this.selector, interestOps);
            } catch(java.lang.IllegalArgumentException ia) {
                throw runtime.newArgumentError("mode not supported for this object: " + interests);
            } catch(java.nio.channels.ClosedChannelException cce) {
                throw context.runtime.newIOError(cce.getLocalizedMessage());
            }
        }

        RubyClass monitorClass = runtime.getModule("NIO").getClass("Monitor");
        Monitor monitor = (Monitor)monitorClass.newInstance(context, io, interests, this, null);
        monitor.setSelectionKey(key);

        return monitor;
    }

    @JRubyMethod
    public IRubyObject deregister(ThreadContext context, IRubyObject io) {
        Ruby runtime = context.getRuntime();
        Channel rawChannel = RubyIO.convertToIO(context, io).getChannel();

        if(!(rawChannel instanceof SelectableChannel)) {
            throw runtime.newArgumentError("not a selectable IO object");
        }

        SelectableChannel channel = (SelectableChannel)rawChannel;
        SelectionKey key = channel.keyFor(this.selector);

        if(key == null)
            return context.nil;

        Monitor monitor = (Monitor)key.attachment();
        monitor.close(context, runtime.getFalse());
        cancelledKeys.put(channel, key);

        return monitor;
    }

    @JRubyMethod(name = "registered?")
    public IRubyObject isRegistered(ThreadContext context, IRubyObject io) {
        Ruby runtime = context.getRuntime();
        Channel rawChannel = RubyIO.convertToIO(context, io).getChannel();

        if(!(rawChannel instanceof SelectableChannel)) {
            throw runtime.newArgumentError("not a selectable IO object");
        }

        SelectableChannel channel = (SelectableChannel)rawChannel;
        SelectionKey key = channel.keyFor(this.selector);

        if(key == null)
            return context.nil;


        if(((Monitor)key.attachment()).isClosed(context) == runtime.getTrue()) {
            return runtime.getFalse();
        } else {
            return runtime.getTrue();
        }
    }

    @JRubyMethod
    public synchronized IRubyObject select(ThreadContext context, Block block) {
        return select(context, context.nil, block);
    }

    @JRubyMethod
    public synchronized IRubyObject select(ThreadContext context, IRubyObject timeout, Block block) {
        Ruby runtime = context.getRuntime();

        if(!this.selector.isOpen()) {
            throw context.getRuntime().newIOError("selector is closed");
        }

        this.wakeupFired = false;
        int ready = doSelect(runtime, context, timeout);

        /* Timeout */
        if(ready <= 0 && !this.wakeupFired) {
            return context.nil;
        }

        RubyArray array = null;

        if(!block.isGiven()) {
            array = runtime.newArray(this.selector.selectedKeys().size());
        }

        Iterator selectedKeys = this.selector.selectedKeys().iterator();
        while(selectedKeys.hasNext()) {
            SelectionKey key = (SelectionKey)selectedKeys.next();
            processKey(key);

            selectedKeys.remove();

            if(block.isGiven()) {
                block.call(context, (IRubyObject)key.attachment());
            } else {
                array.add(key.attachment());
            }
        }

        if(block.isGiven()) {
            return RubyNumeric.int2fix(runtime, ready);
        } else {
            return array;
        }
    }

    /* Run the selector */
    private int doSelect(Ruby runtime, ThreadContext context, IRubyObject timeout) {
        int result;

        cancelKeys();
        try {
            context.getThread().beforeBlockingCall();
            if(timeout.isNil()) {
                result = this.selector.select();
            } else {
                double t = RubyNumeric.num2dbl(timeout);
                if(t == 0) {
                    result = this.selector.selectNow();
                } else if(t < 0) {
                    throw runtime.newArgumentError("time interval must be positive");
                } else {
                    long timeoutMilliSeconds = (long)(t * 1000);
                    if(timeoutMilliSeconds == 0) {
                      result = this.selector.selectNow();
                    } else {
                      result = this.selector.select(timeoutMilliSeconds);
                    }
                }
            }
            context.getThread().afterBlockingCall();
            return result;
        } catch(IOException ie) {
            throw runtime.newIOError(ie.getLocalizedMessage());
        }
    }

    /* Flush our internal buffer of cancelled keys */
    private void cancelKeys() {
        Iterator cancelledKeys = this.cancelledKeys.entrySet().iterator();
        while(cancelledKeys.hasNext()) {
            Map.Entry entry = (Map.Entry)cancelledKeys.next();
            SelectionKey key = (SelectionKey)entry.getValue();
            key.cancel();
            cancelledKeys.remove();
        }
    }

    // Remove connect interest from connected sockets
    // See: http://stackoverflow.com/questions/204186/java-nio-select-returns-without-selected-keys-why
    private void processKey(SelectionKey key) {
        if(key.isValid() && (key.readyOps() & SelectionKey.OP_CONNECT) != 0) {
            int interestOps = key.interestOps();

            interestOps &= ~SelectionKey.OP_CONNECT;
            interestOps |=  SelectionKey.OP_WRITE;

            key.interestOps(interestOps);
        }
    }

    @JRubyMethod
    public IRubyObject wakeup(ThreadContext context) {
        if(!this.selector.isOpen()) {
            throw context.getRuntime().newIOError("selector is closed");
        }

        this.wakeupFired = true;
        this.selector.wakeup();

        return context.nil;
    }
}
