package org.nio4r;

import java.nio.channels.Channel;
import java.nio.channels.SelectableChannel;
import java.nio.channels.SelectionKey;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyIO;
import org.jruby.RubyObject;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;

public class Monitor extends RubyObject {
    private SelectionKey key;
    private RubyIO io;
    private IRubyObject interests, selector, value, closed;

    public Monitor(final Ruby ruby, RubyClass rubyClass) {
        super(ruby, rubyClass);
    }

    @JRubyMethod
    public IRubyObject initialize(ThreadContext context, IRubyObject selectable, IRubyObject interests, IRubyObject selector) {
        this.io        = RubyIO.convertToIO(context, selectable);
        this.interests = interests;
        this.selector  = selector;

        this.value  = context.nil;
        this.closed = context.getRuntime().getFalse();

        return context.nil;
    }

    public void setSelectionKey(SelectionKey key) {
        this.key = key;
        key.attach(this);
    }

    @JRubyMethod
    public IRubyObject io(ThreadContext context) {
        return io;
    }

    @JRubyMethod
    public IRubyObject selector(ThreadContext context) {
        return selector;
    }

    @JRubyMethod(name = "interests")
    public IRubyObject getInterests(ThreadContext context) {
        return interests;
    }

    @JRubyMethod(name = "interests=")
    public IRubyObject setInterests(ThreadContext context, IRubyObject interests) {
        if(this.closed == context.getRuntime().getTrue()) {
            throw context.getRuntime().newEOFError("monitor is closed");
        }

        Ruby ruby = context.getRuntime();
        SelectableChannel channel = (SelectableChannel)io.getChannel();

        if(interests != context.nil) {
            key.interestOps(Nio4r.symbolToInterestOps(ruby, channel, interests));
        } else {
            key.interestOps(0);
        }
        
        this.interests = interests;

        return this.interests;
    }

    @JRubyMethod(name = "add_interest")
    public IRubyObject addInterest(ThreadContext context, IRubyObject interest) {
        if(this.closed == context.getRuntime().getTrue()) {
            throw context.getRuntime().newEOFError("monitor is closed");
        }

        Ruby ruby = context.getRuntime();
        SelectableChannel channel = (SelectableChannel)io.getChannel();
        int newInterestOps = key.interestOps() | Nio4r.symbolToInterestOps(ruby, channel, interest);

        key.interestOps(newInterestOps);
        this.interests = Nio4r.interestOpsToSymbol(ruby, newInterestOps);

        return this.interests;
    }

    @JRubyMethod(name = "remove_interest")
    public IRubyObject removeInterest(ThreadContext context, IRubyObject interest) {
        if(this.closed == context.getRuntime().getTrue()) {
            throw context.getRuntime().newEOFError("monitor is closed");
        }

        Ruby ruby = context.getRuntime();
        SelectableChannel channel = (SelectableChannel)io.getChannel();
        int newInterestOps = key.interestOps() & ~Nio4r.symbolToInterestOps(ruby, channel, interest);

        key.interestOps(newInterestOps);
        this.interests = Nio4r.interestOpsToSymbol(ruby, newInterestOps);

        return this.interests;
    }

    @JRubyMethod
    public IRubyObject readiness(ThreadContext context) {
        if(!key.isValid())
          return this.interests; 
        return Nio4r.interestOpsToSymbol(context.getRuntime(), key.readyOps());
    }

    @JRubyMethod(name = "readable?")
    public IRubyObject isReadable(ThreadContext context) {
        Ruby runtime  = context.getRuntime();
        if (!this.key.isValid())
          return runtime.getTrue();
        int  readyOps = this.key.readyOps();

        if((readyOps & SelectionKey.OP_READ) != 0 || (readyOps & SelectionKey.OP_ACCEPT) != 0) {
            return runtime.getTrue();
        } else {
            return runtime.getFalse();
        }
    }

    @JRubyMethod(name = {"writable?", "writeable?"})
    public IRubyObject writable(ThreadContext context) {
        Ruby runtime  = context.getRuntime();
        if (!this.key.isValid())
          return runtime.getTrue();
        int  readyOps = this.key.readyOps();

        if((readyOps & SelectionKey.OP_WRITE) != 0 || (readyOps & SelectionKey.OP_CONNECT) != 0) {
            return runtime.getTrue();
        } else {
            return runtime.getFalse();
        }
    }

    @JRubyMethod(name = "value")
    public IRubyObject getValue(ThreadContext context) {
        return this.value;
    }

    @JRubyMethod(name = "value=")
    public IRubyObject setValue(ThreadContext context, IRubyObject obj) {
        this.value = obj;
        return context.nil;
    }

    @JRubyMethod
    public IRubyObject close(ThreadContext context) {
        return close(context, context.getRuntime().getTrue());
    }

    @JRubyMethod
    public IRubyObject close(ThreadContext context, IRubyObject deregister) {
        Ruby runtime = context.getRuntime();
        this.closed = runtime.getTrue();

        if(deregister == runtime.getTrue()) {
            selector.callMethod(context, "deregister", io);
        }

        return context.nil;
    }

    @JRubyMethod(name = "closed?")
    public IRubyObject isClosed(ThreadContext context) {
        return this.closed;
    }
}
