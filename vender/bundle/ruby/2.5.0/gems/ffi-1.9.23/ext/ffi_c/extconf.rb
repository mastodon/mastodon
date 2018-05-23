#!/usr/bin/env ruby

if !defined?(RUBY_ENGINE) || RUBY_ENGINE == 'ruby' || RUBY_ENGINE == 'rbx'
  require 'mkmf'
  require 'rbconfig'
  dir_config("ffi_c")

  # recent versions of ruby add restrictive ansi and warning flags on a whim - kill them all
  $warnflags = ''
  $CFLAGS.gsub!(/[\s+]-ansi/, '')
  $CFLAGS.gsub!(/[\s+]-std=[^\s]+/, '')
  # solaris 10 needs -c99 for <stdbool.h>
  $CFLAGS << " -std=c99" if RbConfig::CONFIG['host_os'] =~ /solaris(!?2\.11)/

  if ENV['RUBY_CC_VERSION'].nil? && (pkg_config("libffi") ||
     have_header("ffi.h") ||
     find_header("ffi.h", "/usr/local/include", "/usr/include/ffi"))

    # We need at least ffi_call and ffi_closure_alloc
    libffi_ok = have_library("ffi", "ffi_call", [ "ffi.h" ]) ||
                have_library("libffi", "ffi_call", [ "ffi.h" ])
    libffi_ok &&= have_func("ffi_closure_alloc")

    # Check if the raw api is available.
    $defs << "-DHAVE_RAW_API" if have_func("ffi_raw_call") && have_func("ffi_prep_raw_closure")
  end

  have_header('shlwapi.h')
  have_func('rb_thread_blocking_region')
  have_func('rb_thread_call_with_gvl')
  have_func('rb_thread_call_without_gvl')

  if libffi_ok
    have_func('ffi_prep_cif_var')
  else
    $defs << "-DHAVE_FFI_PREP_CIF_VAR"
  end

  $defs << "-DHAVE_EXTCONF_H" if $defs.empty? # needed so create_header works
  $defs << "-DUSE_INTERNAL_LIBFFI" unless libffi_ok
  $defs << "-DRUBY_1_9" if RUBY_VERSION >= "1.9.0"
  $defs << "-DFFI_BUILDING" if RbConfig::CONFIG['host_os'] =~ /mswin/ # for compatibility with newer libffi

  create_header
  
  $LOCAL_LIBS << " ./libffi/.libs/libffi_convenience.lib" if !libffi_ok && RbConfig::CONFIG['host_os'] =~ /mswin/

  create_makefile("ffi_c")
  unless libffi_ok
    File.open("Makefile", "a") do |mf|
      mf.puts "LIBFFI_HOST=--host=#{RbConfig::CONFIG['host_alias']}" if RbConfig::CONFIG.has_key?("host_alias")
      if RbConfig::CONFIG['host_os'].downcase =~ /darwin/
        mf.puts "include ${srcdir}/libffi.darwin.mk"
      elsif RbConfig::CONFIG['host_os'].downcase =~ /bsd/
        mf.puts '.include "${srcdir}/libffi.bsd.mk"'
      elsif RbConfig::CONFIG['host_os'].downcase =~ /mswin64/
        mf.puts '!include $(srcdir)/libffi.vc64.mk'
      elsif RbConfig::CONFIG['host_os'].downcase =~ /mswin32/
        mf.puts '!include $(srcdir)/libffi.vc.mk'
      else
        mf.puts "include ${srcdir}/libffi.mk"
      end
    end
  end
  
else
  File.open("Makefile", "w") do |mf|
    mf.puts "# Dummy makefile for non-mri rubies"
    mf.puts "all install::\n"
  end
end
