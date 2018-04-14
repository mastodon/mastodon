#ifndef NOKOGIRI_XSLT_STYLESHEET
#define NOKOGIRI_XSLT_STYLESHEET

#include <nokogiri.h>

void init_xslt_stylesheet();

extern VALUE cNokogiriXsltStylesheet ;

typedef struct _nokogiriXsltStylesheetTuple {
  xsltStylesheetPtr ss;
  VALUE func_instances;
} nokogiriXsltStylesheetTuple;
#endif
