########################### vendored from https://github.com/fcheung/going_native_examples ####################################

require 'ffi'
module Objc
  extend FFI::Library
  ffi_lib 'objc', '/System/Library/Frameworks/Foundation.framework/Foundation', '/System/Library/Frameworks/Appkit.framework/Appkit'

  typedef :pointer, :method
  typedef :pointer, :selector
  typedef :pointer, :id
  
  attach_function :NSLog, [:pointer], :void
  attach_function :objc_getClass, [:string], :pointer
  attach_function :sel_registerName, [:string], :selector
  attach_function :objc_msgSend, [:id, :selector, :varargs], :id
  if FFI::Platform::ARCH =~ /i386/
    attach_function :objc_msgSend_f, :objc_msgSend_fpret, [:id, :selector, :varargs], :float
    attach_function :objc_msgSend_d, :objc_msgSend_fpret, [:id, :selector, :varargs], :double
  else
    attach_function :objc_msgSend_f, :objc_msgSend, [:id, :selector, :varargs], :float
    attach_function :objc_msgSend_d, :objc_msgSend, [:id, :selector, :varargs], :double
  end
  
  attach_function :method_getNumberOfArguments, [:method], :uint
  attach_function :class_getInstanceMethod, [:pointer, :selector], :method
  attach_function :class_respondsToSelector, [:pointer, :selector], :uchar
  attach_function :method_getReturnType, [:method, :pointer, :size_t], :void
  attach_function :method_getArgumentType, [:method, :uint, :pointer, :size_t], :void
  attach_function :object_getClass, [:pointer], :pointer

  class Object < FFI::Pointer
    
    def objc_send(args)
      method_name, arguments = extract_arguments_and_method_name args
      selector = Objc.sel_registerName(method_name)
      
      if Objc.class_respondsToSelector(klass, selector).nonzero?
        invoke_selector(selector, arguments)
      else 
        raise NoMethodError, "#{self} does not respond to #{method_name}"
      end
    end
    
    def inspect
      self.class.new(objc_send(:description)).objc_send(cStringUsingEncoding: 4).force_encoding(Encoding::UTF_8)
    end
    
    def method_missing method_name, *args
      if args.any?
        first_arg, hash = *args
        hash ||= {}
        objc_send({method_name => first_arg}.merge(hash))
      else
        objc_send(method_name)
      end
    end
    
    private
    
    def extract_arguments_and_method_name(args)
      case args
      when Symbol,String
        method_name = args.to_s
        arguments = []
      else
        method_name = args.keys.join(':') << ':'
        arguments = args.values 
      end
      return method_name, arguments
    end
        
    def klass
      @klass ||= Objc.object_getClass(self)
    end

    def signature_for_selector selector
      type_buffer = FFI::MemoryPointer.new(:char, 32)
      method = Objc.class_getInstanceMethod(klass, selector)
      Objc.method_getReturnType(method, type_buffer, type_buffer.size)
      return_type = type_buffer.read_string
      #the first 2 arguments are always the receiver and the selector - don't care about those
      arguments =  (2...Objc.method_getNumberOfArguments(method)).collect do |index|
        Objc.method_getArgumentType(method,index,type_buffer, type_buffer.size)
        objc_signature_to_ffi_type(type_buffer.read_string)
      end
      return return_type, arguments
    end
    
    def invoke_selector(selector, arguments)
      return_type_signature, arguments_signature = signature_for_selector(selector)
      args_with_types = arguments_signature.zip(arguments).flatten
      case return_type_signature
      when 'f' then Objc.objc_msgSend_f(self, selector, *args_with_types)
      when 'd' then Objc.objc_msgSend_d(self, selector, *args_with_types)
      else
        pointer = Objc.objc_msgSend(self, selector, *args_with_types)
        pointer && !pointer.null? ? coerce_return_value(pointer, return_type_signature) : nil
      end
    end
    
    def objc_signature_to_ffi_type(signature)
      case signature
      when '@','#',':', '^@' then :pointer
      when '*', 'r*' then :string
      when 'c'  then :char
      when 'C'  then :uchar
      when 's'  then :short
      when 'S'  then :ushort
      when 'i'  then :int
      when 'I'  then :uint
      when 'l'  then :long
      when 'L'  then :ulong
      when 'q'  then :long_long
      when 'Q'  then :ulong_long
      when 'f'  then :float
      when 'd'  then :double
      else
        raise "unhandled argument type #{signature}"
      end
    end
    def coerce_return_value pointer, return_type
      case return_type
      when '@' then Object.new(pointer)
      when 'v' then nil
      when '*', 'r*' then pointer.read_string
      when 'c', 'C', 's', 'S', 'i', 'I', 'l', 'L', 'q', 'Q'
        repack(pointer.address, return_type)
      else
        pointer
      end
    end
    
    def repack(raw, format)
      [raw].pack('Q').unpack(format).first
    end
  end
  
  def self.get_class(name)
    Object.new(objc_getClass(name))
  end
  
  def self.const_missing(name)
    klass = objc_getClass(name.to_s)
    if klass.null?
      super
    else
      const_set(name, Object.new( klass))
    end
  end
  
end

=begin
Objc::NSWorkspace.sharedWorkspace.openFile Objc::NSString.stringWithCString("/Users/fred/going_native_examples/ffi_objc.rb")
path = Objc::NSString.stringWithCString "/Users/fred/Desktop/sound.mp3", encoding: 4
sound = Objc::NSSound.alloc.initWithContentsOfFile path, byReference: 1
x=sound.play
sleep 10
=end
