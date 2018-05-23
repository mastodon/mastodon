#ifndef ext_help_h
#define ext_help_h

#define RAISE_NOT_NULL(T) if(T == NULL) rb_raise(rb_eArgError, "%s", "NULL found for " # T " when shouldn't be.");
#define DATA_GET(from,type,name) Data_Get_Struct(from,type,name); RAISE_NOT_NULL(name);
#define REQUIRE_TYPE(V, T) if(TYPE(V) != T) rb_raise(rb_eTypeError, "%s", "Wrong argument type for " # V " required " # T);
#define ARRAY_SIZE(x) (sizeof(x)/sizeof(x[0]))

#ifdef DEBUG
#define TRACE()  fprintf(stderr, "> %s:%d:%s\n", __FILE__, __LINE__, __FUNCTION__)
#else
#define TRACE() 
#endif

#endif
