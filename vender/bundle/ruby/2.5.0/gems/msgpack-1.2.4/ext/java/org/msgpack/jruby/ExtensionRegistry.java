package org.msgpack.jruby;

import org.jruby.Ruby;
import org.jruby.RubyHash;
import org.jruby.RubyArray;
import org.jruby.RubyModule;
import org.jruby.RubyFixnum;
import org.jruby.RubySymbol;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;

import java.util.Map;
import java.util.HashMap;

public class ExtensionRegistry {
  private final Map<RubyModule, ExtensionEntry> extensionsByModule;
  private final Map<RubyModule, ExtensionEntry> extensionsByAncestor;
  private final ExtensionEntry[] extensionsByTypeId;

  public ExtensionRegistry() {
    this(new HashMap<RubyModule, ExtensionEntry>());
  }

  private ExtensionRegistry(Map<RubyModule, ExtensionEntry> extensionsByModule) {
    this.extensionsByModule = new HashMap<RubyModule, ExtensionEntry>(extensionsByModule);
    this.extensionsByAncestor = new HashMap<RubyModule, ExtensionEntry>();
    this.extensionsByTypeId = new ExtensionEntry[256];
    for (ExtensionEntry entry : extensionsByModule.values()) {
      if (entry.hasUnpacker()) {
        extensionsByTypeId[entry.getTypeId() + 128] = entry;
      }
    }
  }

  public ExtensionRegistry dup() {
    return new ExtensionRegistry(extensionsByModule);
  }

  public IRubyObject toInternalPackerRegistry(ThreadContext ctx) {
    RubyHash hash = RubyHash.newHash(ctx.getRuntime());
    for (RubyModule extensionModule : extensionsByModule.keySet()) {
      ExtensionEntry entry = extensionsByModule.get(extensionModule);
      if (entry.hasPacker()) {
        hash.put(extensionModule, entry.toPackerTuple(ctx));
      }
    }
    return hash;
  }

  public IRubyObject toInternalUnpackerRegistry(ThreadContext ctx) {
    RubyHash hash = RubyHash.newHash(ctx.getRuntime());
    for (int typeIdIndex = 0 ; typeIdIndex < 256 ; typeIdIndex++) {
      ExtensionEntry entry = extensionsByTypeId[typeIdIndex];
      if (entry != null && entry.hasUnpacker()) {
        IRubyObject typeId = RubyFixnum.newFixnum(ctx.getRuntime(), typeIdIndex - 128);
        hash.put(typeId, entry.toUnpackerTuple(ctx));
      }
    }
    return hash;
  }

  public void put(RubyModule mod, int typeId, IRubyObject packerProc, IRubyObject packerArg, IRubyObject unpackerProc, IRubyObject unpackerArg) {
    ExtensionEntry entry = new ExtensionEntry(mod, typeId, packerProc, packerArg, unpackerProc, unpackerArg);
    extensionsByModule.put(mod, entry);
    extensionsByTypeId[typeId + 128] = entry;
    extensionsByAncestor.clear();
  }

  public IRubyObject lookupUnpackerByTypeId(int typeId) {
    ExtensionEntry e = extensionsByTypeId[typeId + 128];
    if (e != null && e.hasUnpacker()) {
      return e.getUnpackerProc();
    } else {
      return null;
    }
  }

  public IRubyObject[] lookupPackerForObject(IRubyObject object) {
    RubyModule lookupClass = null;
    IRubyObject[] pair;
    /*
     * Objects of type Integer (Fixnum, Bignum), Float, Symbol and frozen
     * String have no singleton class and raise a TypeError when trying to get
     * it.
     *
     * Since all but symbols are already filtered out when reaching this code
     * only symbols are checked here.
     */
    if (!(object instanceof RubySymbol)) {
      lookupClass = object.getSingletonClass();
      pair = fetchEntryByModule(lookupClass);
      if (pair != null) {
          return pair;
      }
    }

    pair = fetchEntryByModule(object.getType());
    if (pair != null) {
      return pair;
    }

    if (lookupClass == null) {
      lookupClass = object.getType(); // only for Symbol
    }
    ExtensionEntry e = findEntryByModuleOrAncestor(lookupClass);
    if (e != null && e.hasPacker()) {
      extensionsByAncestor.put(e.getExtensionModule(), e);
      return e.toPackerProcTypeIdPair(lookupClass.getRuntime().getCurrentContext());
    }
    return null;
  }

  private IRubyObject[] fetchEntryByModule(final RubyModule mod) {
    ExtensionEntry e = extensionsByModule.get(mod);
    if (e == null) {
      e = extensionsByAncestor.get(mod);
    }
    if (e != null && e.hasPacker()) {
      return e.toPackerProcTypeIdPair(mod.getRuntime().getCurrentContext());
    }
    return null;
  }

  private ExtensionEntry findEntryByModuleOrAncestor(final RubyModule mod) {
    ThreadContext ctx = mod.getRuntime().getCurrentContext();
    for (RubyModule extensionModule : extensionsByModule.keySet()) {
      RubyArray ancestors = (RubyArray) mod.callMethod(ctx, "ancestors");
      if (ancestors.callMethod(ctx, "include?", extensionModule).isTrue()) {
        return extensionsByModule.get(extensionModule);
      }
    }
    return null;
  }

  private static class ExtensionEntry {
    private final RubyModule mod;
    private final int typeId;
    private final IRubyObject packerProc;
    private final IRubyObject packerArg;
    private final IRubyObject unpackerProc;
    private final IRubyObject unpackerArg;

    public ExtensionEntry(RubyModule mod, int typeId, IRubyObject packerProc, IRubyObject packerArg, IRubyObject unpackerProc, IRubyObject unpackerArg) {
      this.mod = mod;
      this.typeId = typeId;
      this.packerProc = packerProc;
      this.packerArg = packerArg;
      this.unpackerProc = unpackerProc;
      this.unpackerArg = unpackerArg;
    }

    public RubyModule getExtensionModule() {
      return mod;
    }

    public int getTypeId() {
      return typeId;
    }

    public boolean hasPacker() {
      return packerProc != null;
    }

    public boolean hasUnpacker() {
      return unpackerProc != null;
    }

    public IRubyObject getPackerProc() {
      return packerProc;
    }

    public IRubyObject getUnpackerProc() {
      return unpackerProc;
    }

    public RubyArray toPackerTuple(ThreadContext ctx) {
      return RubyArray.newArray(ctx.getRuntime(), new IRubyObject[] {RubyFixnum.newFixnum(ctx.getRuntime(), typeId), packerProc, packerArg});
    }

    public RubyArray toUnpackerTuple(ThreadContext ctx) {
      return RubyArray.newArray(ctx.getRuntime(), new IRubyObject[] {mod, unpackerProc, unpackerArg});
    }

    public IRubyObject[] toPackerProcTypeIdPair(ThreadContext ctx) {
      return new IRubyObject[] {packerProc, RubyFixnum.newFixnum(ctx.getRuntime(), typeId)};
    }
  }
}
