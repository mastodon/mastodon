package org.nio4r;

import java.nio.channels.SelectableChannel;
import java.nio.channels.SelectionKey;
import java.nio.channels.SocketChannel;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.load.Library;
import org.jruby.runtime.builtin.IRubyObject;

import org.nio4r.ByteBuffer;
import org.nio4r.Monitor;
import org.nio4r.Selector;

public class Nio4r implements Library {
    private Ruby ruby;

    public void load(final Ruby ruby, boolean bln) {
        this.ruby = ruby;

        RubyModule nio = ruby.defineModule("NIO");

        RubyClass selector = ruby.defineClassUnder("Selector", ruby.getObject(), new ObjectAllocator() {
            public IRubyObject allocate(Ruby ruby, RubyClass rc) {
                return new Selector(ruby, rc);
            }
        }, nio);

        selector.defineAnnotatedMethods(Selector.class);

        RubyClass monitor = ruby.defineClassUnder("Monitor", ruby.getObject(), new ObjectAllocator() {
            public IRubyObject allocate(Ruby ruby, RubyClass rc) {
                return new Monitor(ruby, rc);
            }
        }, nio);

        monitor.defineAnnotatedMethods(Monitor.class);

        RubyClass byteBuffer = ruby.defineClassUnder("ByteBuffer", ruby.getObject(), new ObjectAllocator() {
            public IRubyObject allocate(Ruby ruby, RubyClass rc) {
                return new ByteBuffer(ruby, rc);
            }
        }, nio);

        byteBuffer.defineAnnotatedMethods(ByteBuffer.class);
        byteBuffer.includeModule(ruby.getEnumerable());

        ruby.defineClassUnder("OverflowError",  ruby.getIOError(), ruby.getIOError().getAllocator(), byteBuffer);
        ruby.defineClassUnder("UnderflowError", ruby.getIOError(), ruby.getIOError().getAllocator(), byteBuffer);
        ruby.defineClassUnder("MarkUnsetError", ruby.getIOError(), ruby.getIOError().getAllocator(), byteBuffer);
    }

    public static int symbolToInterestOps(Ruby ruby, SelectableChannel channel, IRubyObject interest) {
        if(interest == ruby.newSymbol("r")) {
            if((channel.validOps() & SelectionKey.OP_ACCEPT) != 0) {
              return SelectionKey.OP_ACCEPT;
            } else {
              return SelectionKey.OP_READ;
            }
        } else if(interest == ruby.newSymbol("w")) {
            if(channel instanceof SocketChannel && !((SocketChannel)channel).isConnected()) {
                return SelectionKey.OP_CONNECT;
            } else {
                return SelectionKey.OP_WRITE;
            }
        } else if(interest == ruby.newSymbol("rw")) {
            int interestOps = 0;

            /* nio4r emulates the POSIX behavior, which is sloppy about allowed modes */
            if((channel.validOps() & (SelectionKey.OP_READ | SelectionKey.OP_ACCEPT)) != 0) {
                interestOps |= symbolToInterestOps(ruby, channel, ruby.newSymbol("r"));
            }

            if((channel.validOps() & (SelectionKey.OP_WRITE | SelectionKey.OP_CONNECT)) != 0) {
                interestOps |= symbolToInterestOps(ruby, channel, ruby.newSymbol("w"));
            }

            return interestOps;
        } else {
            throw ruby.newArgumentError("invalid interest type: " + interest);
        }
    }

    public static IRubyObject interestOpsToSymbol(Ruby ruby, int interestOps) {
        switch(interestOps) {
            case SelectionKey.OP_READ:
            case SelectionKey.OP_ACCEPT:
                return ruby.newSymbol("r");
            case SelectionKey.OP_WRITE:
            case SelectionKey.OP_CONNECT:
                return ruby.newSymbol("w");
            case SelectionKey.OP_READ | SelectionKey.OP_CONNECT:
            case SelectionKey.OP_READ | SelectionKey.OP_WRITE:
                return ruby.newSymbol("rw");
            case 0:
                return ruby.getNil();
            default:
                throw ruby.newArgumentError("unknown interest op combination");
        }
    }
}
