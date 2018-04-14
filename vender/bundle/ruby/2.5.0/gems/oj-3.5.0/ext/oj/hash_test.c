/* hash_test.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *  - Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 
 *  - Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 *  - Neither the name of Peter Ohler nor the names of its contributors may be
 *    used to endorse or promote products derived from this software without
 *    specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// if windows, comment out the whole file. It's only a performance test.
#ifndef _WIN32
#include <sys/time.h>
#include <time.h>
#include "hash.h"
#include <stdint.h>

/* Define printf formats for standard types, like PRIu64 for uint64_t. */
#define __STDC_FORMAT_MACROS
#include <inttypes.h>

typedef struct _StrLen {
    const char	*str;
    size_t	len;
} *StrLen;

static struct _StrLen data[] = {
    { "Gem::Version", 12 },
    { "TracePoint", 10 },
    { "Complex::compatible", 19 },
    { "Complex", 7 },
    { "Rational::compatible", 20 },
    { "Rational", 8 },
    { "FiberError", 10 },
    { "Fiber", 5 },
    { "ThreadError", 11 },
    { "Mutex", 5 },
    { "ThreadGroup", 11 },
    { "RubyVM::InstructionSequence", 27 },
    { "Thread::Backtrace::Location", 27 },
    { "Thread::Backtrace", 17 },
    { "Thread", 6 },
    { "RubyVM::Env", 11 },
    { "RubyVM", 6 },
    { "Enumerator::Yielder", 19 },
    { "Enumerator::Generator", 21 },
    { "StopIteration", 13 },
    { "Enumerator::Lazy", 16 },
    { "Enumerator", 10 },
    { "ObjectSpace::WeakMap", 20 },
    { "Math::DomainError", 17 },
    { "Binding", 7 },
    { "UnboundMethod", 13 },
    { "Method", 6 },
    { "SystemStackError", 16 },
    { "LocalJumpError", 14 },
    { "Proc", 4 },
    { "Struct::Tms", 11 },
    { "Process::Status", 15 },
    { "Random", 6 },
    { "Time", 4 },
    { "Dir", 3 },
    { "File::Stat", 10 },
    { "File", 4 },
    { "ARGF.class", 10 },
    { "IO", 2 },
    { "EOFError", 8 },
    { "IOError", 7 },
    { "Range", 5 },
    { "Encoding::Converter", 19 },
    { "Encoding::ConverterNotFoundError", 32 },
    { "Encoding::InvalidByteSequenceError", 34 },
    { "Encoding::UndefinedConversionError", 34 },
    { "MatchData", 9 },
    { "Regexp", 6 },
    { "RegexpError", 11 },
    { "Struct", 6 },
    { "Hash", 4 },
    { "Array", 5 },
    { "Errno::ERPCMISMATCH", 19 },
    { "Errno::EPROGUNAVAIL", 19 },
    { "Errno::EPROGMISMATCH", 20 },
    { "Errno::EPROCUNAVAIL", 19 },
    { "Errno::EPROCLIM", 15 },
    { "Errno::ENOTSUP", 14 },
    { "Errno::ENOATTR", 14 },
    { "Errno::ENEEDAUTH", 16 },
    { "Errno::EFTYPE", 13 },
    { "Errno::EBADRPC", 14 },
    { "Errno::EAUTH", 12 },
    { "Errno::EOWNERDEAD", 17 },
    { "Errno::ENOTRECOVERABLE", 22 },
    { "Errno::ECANCELED", 16 },
    { "Errno::EDQUOT", 13 },
    { "Errno::ESTALE", 13 },
    { "Errno::EINPROGRESS", 18 },
    { "Errno::EALREADY", 15 },
    { "Errno::EHOSTUNREACH", 19 },
    { "Errno::EHOSTDOWN", 16 },
    { "Errno::ECONNREFUSED", 19 },
    { "Errno::ETIMEDOUT", 16 },
    { "Errno::ETOOMANYREFS", 19 },
    { "Errno::ESHUTDOWN", 16 },
    { "Errno::ENOTCONN", 15 },
    { "Errno::EISCONN", 14 },
    { "Errno::ENOBUFS", 14 },
    { "Errno::ECONNRESET", 17 },
    { "Errno::ECONNABORTED", 19 },
    { "Errno::ENETRESET", 16 },
    { "Errno::ENETUNREACH", 18 },
    { "Errno::ENETDOWN", 15 },
    { "Errno::EADDRNOTAVAIL", 20 },
    { "Errno::EADDRINUSE", 17 },
    { "Errno::EAFNOSUPPORT", 19 },
    { "Errno::EPFNOSUPPORT", 19 },
    { "Errno::EOPNOTSUPP", 17 },
    { "Errno::ESOCKTNOSUPPORT", 22 },
    { "Errno::EPROTONOSUPPORT", 22 },
    { "Errno::ENOPROTOOPT", 18 },
    { "Errno::EPROTOTYPE", 17 },
    { "Errno::EMSGSIZE", 15 },
    { "Errno::EDESTADDRREQ", 19 },
    { "Errno::ENOTSOCK", 15 },
    { "Errno::EUSERS", 13 },
    { "Errno::EILSEQ", 13 },
    { "Errno::EOVERFLOW", 16 },
    { "Errno::EBADMSG", 14 },
    { "Errno::EMULTIHOP", 16 },
    { "Errno::EPROTO", 13 },
    { "Errno::ENOLINK", 14 },
    { "Errno::EREMOTE", 14 },
    { "Errno::ENOSR", 12 },
    { "Errno::ETIME", 12 },
    { "Errno::ENODATA", 14 },
    { "Errno::ENOSTR", 13 },
    { "Errno::EIDRM", 12 },
    { "Errno::ENOMSG", 13 },
    { "Errno::ELOOP", 12 },
    { "Errno::ENOTEMPTY", 16 },
    { "Errno::ENOSYS", 13 },
    { "Errno::ENOLCK", 13 },
    { "Errno::ENAMETOOLONG", 19 },
    { "Errno::EDEADLK", 14 },
    { "Errno::ERANGE", 13 },
    { "Errno::EDOM", 11 },
    { "Errno::EPIPE", 12 },
    { "Errno::EMLINK", 13 },
    { "Errno::EROFS", 12 },
    { "Errno::ESPIPE", 13 },
    { "Errno::ENOSPC", 13 },
    { "Errno::EFBIG", 12 },
    { "Errno::ETXTBSY", 14 },
    { "Errno::ENOTTY", 13 },
    { "Errno::EMFILE", 13 },
    { "Errno::ENFILE", 13 },
    { "Errno::EINVAL", 13 },
    { "Errno::EISDIR", 13 },
    { "Errno::ENOTDIR", 14 },
    { "Errno::ENODEV", 13 },
    { "Errno::EXDEV", 12 },
    { "Errno::EEXIST", 13 },
    { "Errno::EBUSY", 12 },
    { "Errno::ENOTBLK", 14 },
    { "Errno::EFAULT", 13 },
    { "Errno::EACCES", 13 },
    { "Errno::ENOMEM", 13 },
    { "Errno::EAGAIN", 13 },
    { "Errno::ECHILD", 13 },
    { "Errno::EBADF", 12 },
    { "Errno::ENOEXEC", 14 },
    { "Errno::E2BIG", 12 },
    { "Errno::ENXIO", 12 },
    { "Errno::EIO", 10 },
    { "Errno::EINTR", 12 },
    { "Errno::ESRCH", 12 },
    { "Errno::ENOENT", 13 },
    { "Errno::EPERM", 12 },
    { "Errno::NOERROR", 14 },
    { "Bignum", 6 },
    { "Float", 5 },
    { "Fixnum", 6 },
    { "Integer", 7 },
    { "Numeric", 7 },
    { "FloatDomainError", 16 },
    { "ZeroDivisionError", 17 },
    { "SystemCallError", 15 },
    { "Encoding::CompatibilityError", 28 },
    { "EncodingError", 13 },
    { "NoMemoryError", 13 },
    { "SecurityError", 13 },
    { "RuntimeError", 12 },
    { "NoMethodError", 13 },
    { "NameError::message", 18 },
    { "NameError", 9 },
    { "NotImplementedError", 19 },
    { "LoadError", 9 },
    { "SyntaxError", 11 },
    { "ScriptError", 11 },
    { "RangeError", 10 },
    { "KeyError", 8 },
    { "IndexError", 10 },
    { "ArgumentError", 13 },
    { "TypeError", 9 },
    { "StandardError", 13 },
    { "Interrupt", 9 },
    { "SignalException", 15 },
    { "SystemExit", 10 },
    { "Exception", 9 },
    { "Symbol", 6 },
    { "String", 6 },
    { "Encoding", 8 },
    { "FalseClass", 10 },
    { "TrueClass", 9 },
    { "Data", 4 },
    { "NilClass", 8 },
    { "Class", 5 },
    { "Module", 6 },
    { "Object", 6 },
    { "BasicObject", 11 },
    { "Gem::Requirement::BadRequirementError", 37 },
    { "Gem::Requirement", 16 },
    { "Gem::SourceFetchProblem", 23 },
    { "Gem::PlatformMismatch", 21 },
    { "Gem::ErrorReason", 16 },
    { "Gem::LoadError", 14 },
    { "Gem::RemoteSourceException", 26 },
    { "Gem::RemoteInstallationSkipped", 30 },
    { "Gem::RemoteInstallationCancelled", 32 },
    { "Gem::RemoteError", 16 },
    { "Gem::OperationNotSupportedError", 31 },
    { "Gem::InvalidSpecificationException", 34 },
    { "Gem::InstallError", 17 },
    { "Gem::Specification", 18 },
    { "Date", 4 },
    { "Gem::Platform", 13 },
    { "Gem::SpecificGemNotFoundException", 33 },
    { "Gem::GemNotFoundException", 25 },
    { "Gem::FormatException", 20 },
    { "Gem::FilePermissionError", 24 },
    { "Gem::EndOfYAMLException", 23 },
    { "Gem::DocumentError", 18 },
    { "Gem::GemNotInHomeException", 26 },
    { "Gem::DependencyRemovalException", 31 },
    { "Gem::DependencyError", 20 },
    { "Gem::CommandLineError", 21 },
    { "Gem::Exception", 14 },
    { "IRB::SLex", 9 },
    { "IRB::Notifier::NoMsgNotifier", 28 },
    { "IRB::Notifier::LeveledNotifier", 30 },
    { "IRB::Notifier::CompositeNotifier", 32 },
    { "IRB::Notifier::AbstractNotifier", 31 },
    { "IRB::Notifier::ErrUnrecognizedLevel", 35 },
    { "IRB::Notifier::ErrUndefinedNotifier", 35 },
    { "IRB::StdioOutputMethod", 22 },
    { "IRB::OutputMethod::NotImplementedError", 38 },
    { "IRB::OutputMethod", 17 },
    { "IRB::IllegalRCGenerator", 23 },
    { "IRB::UndefinedPromptMode", 24 },
    { "IRB::CantChangeBinding", 22 },
    { "IRB::CantShiftToMultiIrbMode", 28 },
    { "IRB::NoSuchJob", 14 },
    { "IRB::IrbSwitchedToCurrentThread", 31 },
    { "IRB::IrbAlreadyDead", 19 },
    { "IRB::IllegalParameter", 21 },
    { "IRB::CantReturnToNormalMode", 27 },
    { "IRB::NotImplementedError", 24 },
    { "IRB::UnrecognizedSwitch", 23 },
    { "IRB::Irb", 8 },
    { "IRB::Abort", 10 },
    { "IRB::Locale", 11 },
    { "IRB::SLex::ErrNodeNothing", 25 },
    { "IRB::SLex::ErrNodeAlreadyExists", 31 },
    { "RubyLex", 7 },
    { "IRB::SLex::Node", 15 },
    { "Gem::SystemExitException", 24 },
    { "Gem::VerificationError", 22 },
    { "RubyToken::TkError", 18 },
    { "RubyToken::TkUnknownChar", 24 },
    { "RubyToken::TkOPASGN", 19 },
    { "RubyToken::TkOp", 15 },
    { "RubyToken::TkVal", 16 },
    { "RubyToken::TkId", 15 },
    { "RubyToken::TkNode", 17 },
    { "RubyToken::Token", 16 },
    { "RubyToken::TkUNDEF", 18 },
    { "RubyToken::TkDEF", 16 },
    { "RubyToken::TkMODULE", 19 },
    { "RubyToken::TkCLASS", 18 },
    { "RubyToken::TkWHILE", 18 },
    { "RubyToken::TkWHEN", 17 },
    { "RubyToken::TkCASE", 17 },
    { "RubyToken::TkELSE", 17 },
    { "RubyToken::TkELSIF", 18 },
    { "RubyToken::TkTHEN", 17 },
    { "RubyToken::TkUNLESS", 19 },
    { "RubyToken::TkIF", 15 },
    { "RubyToken::TkEND", 16 },
    { "RubyToken::TkENSURE", 19 },
    { "RubyToken::TkRESCUE", 19 },
    { "RubyToken::TkBEGIN", 18 },
    { "RubyToken::TkDO", 15 },
    { "RubyToken::TkIN", 15 },
    { "RubyToken::TkRETRY", 18 },
    { "RubyToken::TkREDO", 17 },
    { "RubyToken::TkNEXT", 17 },
    { "RubyToken::TkBREAK", 18 },
    { "RubyToken::TkFOR", 16 },
    { "RubyToken::TkUNTIL", 18 },
    { "RubyToken::TkTRUE", 17 },
    { "RubyToken::TkNIL", 16 },
    { "RubyToken::TkSELF", 17 },
    { "RubyToken::TkSUPER", 18 },
    { "RubyToken::TkYIELD", 18 },
    { "RubyToken::TkRETURN", 19 },
    { "RubyToken::TkAND", 16 },
    { "RubyToken::TkFALSE", 18 },
    { "RubyToken::TkUNLESS_MOD", 23 },
    { "RubyToken::TkIF_MOD", 19 },
    { "RubyToken::TkNOT", 16 },
    { "RubyToken::TkOR", 15 },
    { "RubyToken::TkALIAS", 18 },
    { "RubyToken::TkUNTIL_MOD", 22 },
    { "RubyToken::TkWHILE_MOD", 22 },
    { "RubyToken::TkGVAR", 17 },
    { "RubyToken::TkFID", 16 },
    { "RubyToken::TkIDENTIFIER", 23 },
    { "RubyToken::Tk__FILE__", 21 },
    { "RubyToken::Tk__LINE__", 21 },
    { "RubyToken::TklEND", 17 },
    { "RubyToken::TklBEGIN", 19 },
    { "RubyToken::TkDEFINED", 20 },
    { "RubyToken::TkDREGEXP", 20 },
    { "RubyToken::TkDXSTRING", 21 },
    { "RubyToken::TkDSTRING", 20 },
    { "RubyToken::TkSYMBOL", 19 },
    { "RubyToken::TkREGEXP", 19 },
    { "RubyToken::TkXSTRING", 20 },
    { "RubyToken::TkSTRING", 19 },
    { "RubyToken::TkFLOAT", 18 },
    { "RubyToken::TkINTEGER", 20 },
    { "RubyToken::TkCONSTANT", 21 },
    { "RubyToken::TkIVAR", 17 },
    { "RubyToken::TkCVAR", 17 },
    { "RubyToken::TkNEQ", 16 },
    { "RubyToken::TkEQQ", 16 },
    { "RubyToken::TkEQ", 15 },
    { "RubyToken::TkCMP", 16 },
    { "RubyToken::TkPOW", 16 },
    { "RubyToken::TkUMINUS", 19 },
    { "RubyToken::TkUPLUS", 18 },
    { "Exception2MessageMapper::ErrNotRegisteredException", 50 },
    { "RubyToken::TkBACK_REF", 21 },
    { "RubyToken::TkNTH_REF", 20 },
    { "RubyToken::TkLSHFT", 18 },
    { "RubyToken::TkASET", 17 },
    { "RubyToken::TkAREF", 17 },
    { "RubyToken::TkDOT3", 17 },
    { "RubyToken::TkDOT2", 17 },
    { "RubyToken::TkNMATCH", 19 },
    { "RubyToken::TkMATCH", 18 },
    { "RubyToken::TkOROP", 17 },
    { "RubyToken::TkANDOP", 18 },
    { "RubyToken::TkLEQ", 16 },
    { "RubyToken::TkGEQ", 16 },
    { "RubyToken::TkAMPER", 18 },
    { "RubyToken::TkSTAR", 17 },
    { "RubyToken::TkfLBRACE", 20 },
    { "RubyToken::TkfLBRACK", 20 },
    { "RubyToken::TkfLPAREN", 20 },
    { "RubyToken::TkCOLON", 18 },
    { "RubyToken::TkQUESTION", 21 },
    { "RubyToken::TkASSOC", 18 },
    { "RubyToken::TkCOLON3", 19 },
    { "RubyToken::TkCOLON2", 19 },
    { "RubyToken::TkRSHFT", 18 },
    { "RubyToken::TkBITAND", 19 },
    { "RubyToken::TkBITXOR", 19 },
    { "RubyToken::TkBITOR", 18 },
    { "RubyToken::TkMOD", 16 },
    { "RubyToken::TkDIV", 16 },
    { "RubyToken::TkMULT", 17 },
    { "RubyToken::TkMINUS", 18 },
    { "RubyToken::TkPLUS", 17 },
    { "RubyToken::TkLT", 15 },
    { "RubyToken::TkGT", 15 },
    { "RubyToken::TkSYMBEG", 19 },
    { "IRB::DefaultEncodings", 21 },
    { "RubyToken::TkRPAREN", 19 },
    { "RubyToken::TkLBRACE", 19 },
    { "RubyToken::TkLBRACK", 19 },
    { "RubyToken::TkLPAREN", 19 },
    { "RubyToken::TkDOT", 16 },
    { "RubyToken::TkASSIGN", 19 },
    { "RubyToken::TkBACKQUOTE", 22 },
    { "RubyToken::TkNOTOP", 18 },
    { "RubyToken::TkBITNOT", 19 },
    { "RubyToken::TkDOLLAR", 19 },
    { "RubyToken::TkAT", 15 },
    { "RubyToken::TkBACKSLASH", 22 },
    { "RubyToken::TkEND_OF_SCRIPT", 26 },
    { "RubyToken::TkNL", 15 },
    { "RubyToken::TkSPACE", 18 },
    { "RubyToken::TkRD_COMMENT", 23 },
    { "RubyToken::TkCOMMENT", 20 },
    { "RubyToken::TkSEMICOLON", 22 },
    { "RubyToken::TkCOMMA", 18 },
    { "RubyToken::TkRBRACE", 19 },
    { "RubyToken::TkRBRACK", 19 },
    { "RubyLex::TerminateLineInput", 27 },
    { "RubyLex::SyntaxError", 20 },
    { "RubyLex::TkReading2TokenDuplicateError", 38 },
    { "RubyLex::TkSymbol2TokenNoKey", 28 },
    { "RubyLex::TkReading2TokenNoKey", 29 },
    { "RubyLex::AlreadyDefinedToken", 28 },
    { "IRB::FileInputMethod", 20 },
    { "IRB::StdioInputMethod", 21 },
    { "IRB::InputMethod", 16 },
    { "IRB::ReadlineInputMethod", 24 },
    { "IRB::Context", 12 },
    { "IRB::Inspector", 14 },
    { "IRB::WorkSpace", 14 },
    { 0, 0 }
};

static uint64_t
micro_time() {
    struct timeval	tv;

    gettimeofday(&tv, NULL);

    return (uint64_t)tv.tv_sec * 1000000ULL + (uint64_t)tv.tv_usec;
}

static void
perf() {
    StrLen	d;
    VALUE	v;
    VALUE	*slot = 0;
    uint64_t	dt, start;
    int		i, iter = 1000000;
    int		dataCnt = sizeof(data) / sizeof(*data);

    oj_hash_init();
    start = micro_time();
    for (i = iter; 0 < i; i--) {
	for (d = data; 0 != d->str; d++) {
	    v = oj_class_hash_get(d->str, d->len, &slot);
	    if (Qundef == v) {
		if (0 != slot) {
		    v = ID2SYM(rb_intern(d->str));
		    *slot = v;
		}
	    }
	}
    }
    dt = micro_time() - start;
#if IS_WINDOWS
    printf("%d iterations took %ld msecs, %ld gets/msec\n", iter, (long)(dt / 1000), (long)(iter * dataCnt / (dt / 1000)));
#else
    printf("%d iterations took %"PRIu64" msecs, %ld gets/msec\n", iter, dt / 1000, (long)(iter * dataCnt / (dt / 1000)));
#endif
}

void
oj_hash_test() {
    StrLen	d;
    VALUE	v;
    VALUE	*slot = 0;;

    oj_hash_init();
    for (d = data; 0 != d->str; d++) {
	char	*s = oj_strndup(d->str, d->len);
	v = oj_class_hash_get(d->str, d->len, &slot);
	if (Qnil == v) {
	    if (0 == slot) {
		printf("*** failed to get a slot for %s\n", s);
	    } else {
		v = ID2SYM(rb_intern(d->str));
		*slot = v;
	    }
	} else {
	    VALUE	rs = rb_funcall2(v, rb_intern("to_s"), 0, 0);

	    printf("*** get on '%s' returned '%s' (%s)\n", s, StringValuePtr(rs), rb_class2name(rb_obj_class(v)));
	}
	/*oj_hash_print(c);*/
    }
    printf("*** ---------- hash table ------------\n");
    oj_hash_print();
    perf();
}
#endif
