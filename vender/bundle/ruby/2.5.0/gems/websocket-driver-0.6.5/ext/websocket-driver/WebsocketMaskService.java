package com.jcoglan.websocket;

import java.lang.Long;
import java.io.IOException;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.RubyObject;
import org.jruby.RubyString;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.load.BasicLibraryService;

public class WebsocketMaskService implements BasicLibraryService {
  private Ruby runtime;

  public boolean basicLoad(Ruby runtime) throws IOException {
    this.runtime = runtime;
    RubyModule websocket = runtime.defineModule("WebSocket");

    RubyClass webSocketMask = websocket.defineClassUnder("Mask", runtime.getObject(), new ObjectAllocator() {
      public IRubyObject allocate(Ruby runtime, RubyClass rubyClass) {
        return new WebsocketMask(runtime, rubyClass);
      }
    });

    webSocketMask.defineAnnotatedMethods(WebsocketMask.class);
    return true;
  }

  public class WebsocketMask extends RubyObject {
    public WebsocketMask(final Ruby runtime, RubyClass rubyClass) {
      super(runtime, rubyClass);
    }

    @JRubyMethod
    public IRubyObject mask(ThreadContext context, IRubyObject payload, IRubyObject mask) {
      if (mask.isNil()) return payload;

      byte[] payload_a = ((RubyString)payload).getBytes();
      byte[] mask_a    = ((RubyString)mask).getBytes();
      int i, n         = payload_a.length;

      if (n == 0) return payload;

      for (i = 0; i < n; i++) {
        payload_a[i] ^= mask_a[i % 4];
      }
      return RubyString.newStringNoCopy(runtime, payload_a);
    }
  }
}
