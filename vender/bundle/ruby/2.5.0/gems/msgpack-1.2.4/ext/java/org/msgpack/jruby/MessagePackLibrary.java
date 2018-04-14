package org.msgpack.jruby;


import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyClass;
import org.jruby.RubyString;
import org.jruby.RubyNil;
import org.jruby.RubyBoolean;
import org.jruby.RubyHash;
import org.jruby.runtime.load.Library;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.Block;
import org.jruby.runtime.Visibility;
import org.jruby.anno.JRubyModule;
import org.jruby.anno.JRubyMethod;
import org.jruby.internal.runtime.methods.CallConfiguration;
import org.jruby.internal.runtime.methods.DynamicMethod;


public class MessagePackLibrary implements Library {
  public void load(Ruby runtime, boolean wrap) {
    RubyModule msgpackModule = runtime.defineModule("MessagePack");
    RubyClass standardErrorClass = runtime.getStandardError();
    RubyClass unpackErrorClass = msgpackModule.defineClassUnder("UnpackError", standardErrorClass, standardErrorClass.getAllocator());
    RubyClass underflowErrorClass = msgpackModule.defineClassUnder("UnderflowError", unpackErrorClass, unpackErrorClass.getAllocator());
    RubyClass malformedFormatErrorClass = msgpackModule.defineClassUnder("MalformedFormatError", unpackErrorClass, unpackErrorClass.getAllocator());
    RubyClass stackErrorClass = msgpackModule.defineClassUnder("StackError", unpackErrorClass, unpackErrorClass.getAllocator());
    RubyModule typeErrorModule = msgpackModule.defineModuleUnder("TypeError");
    RubyClass unexpectedTypeErrorClass = msgpackModule.defineClassUnder("UnexpectedTypeError", unpackErrorClass, unpackErrorClass.getAllocator());
    unexpectedTypeErrorClass.includeModule(typeErrorModule);
    RubyClass unknownExtTypeErrorClass = msgpackModule.defineClassUnder("UnknownExtTypeError", unpackErrorClass, unpackErrorClass.getAllocator());
    RubyClass extensionValueClass = msgpackModule.defineClassUnder("ExtensionValue", runtime.getObject(), new ExtensionValue.ExtensionValueAllocator());
    extensionValueClass.defineAnnotatedMethods(ExtensionValue.class);
    RubyClass packerClass = msgpackModule.defineClassUnder("Packer", runtime.getObject(), new Packer.PackerAllocator());
    packerClass.defineAnnotatedMethods(Packer.class);
    RubyClass unpackerClass = msgpackModule.defineClassUnder("Unpacker", runtime.getObject(), new Unpacker.UnpackerAllocator());
    unpackerClass.defineAnnotatedMethods(Unpacker.class);
    RubyClass bufferClass = msgpackModule.defineClassUnder("Buffer", runtime.getObject(), new Buffer.BufferAllocator());
    bufferClass.defineAnnotatedMethods(Buffer.class);
    RubyClass factoryClass = msgpackModule.defineClassUnder("Factory", runtime.getObject(), new Factory.FactoryAllocator());
    factoryClass.defineAnnotatedMethods(Factory.class);
  }
}
