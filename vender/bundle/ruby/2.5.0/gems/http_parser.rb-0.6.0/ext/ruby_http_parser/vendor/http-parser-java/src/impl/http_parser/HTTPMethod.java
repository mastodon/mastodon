package http_parser;

import java.nio.charset.Charset;

public enum HTTPMethod {
    HTTP_DELETE("DELETE")//    = 0
  , HTTP_GET("GET")
  , HTTP_HEAD("HEAD")
  , HTTP_POST("POST")
  , HTTP_PUT("PUT")
  , HTTP_PATCH("PATCH")
  /* pathological */
  , HTTP_CONNECT("CONNECT")
  , HTTP_OPTIONS("OPTIONS")
  , HTTP_TRACE("TRACE")
  /* webdav */
  , HTTP_COPY("COPY")
  , HTTP_LOCK("LOCK")
  , HTTP_MKCOL("MKCOL")
  , HTTP_MOVE("MOVE")
  , HTTP_PROPFIND("PROPFIND")
  , HTTP_PROPPATCH("PROPPATCH")
  , HTTP_UNLOCK("UNLOCK")
  , HTTP_REPORT("REPORT")
  , HTTP_MKACTIVITY("MKACTIVITY")
  , HTTP_CHECKOUT("CHECKOUT")
  , HTTP_MERGE("MERGE")
  , HTTP_MSEARCH("M-SEARCH")
  , HTTP_NOTIFY("NOTIFY")
  , HTTP_SUBSCRIBE("SUBSCRIBE")
  , HTTP_UNSUBSCRIBE("UNSUBSCRIBE")
  , HTTP_PURGE("PURGE")
  ;

  private static Charset ASCII;
  static {
    ASCII = Charset.forName("US-ASCII");;
  }
  public byte[] bytes;

  HTTPMethod(String name) {
    // good grief, Charlie Brown, the following is necessary because
    // java is retarded:
    // illegal reference to static field from initializer
    //            this.bytes = name.getBytes(ASCII);
    // yet it's not illegal to reference static fields from
    // methods called from initializer.
    init(name);
  }
  public static HTTPMethod parse(String s) {
         if ("HTTP_DELETE".equalsIgnoreCase(s))  {return HTTP_DELETE;}
    else if ("DELETE".equalsIgnoreCase(s))       {return HTTP_DELETE;}
    else if ("HTTP_GET".equalsIgnoreCase(s))     {return HTTP_GET;}
    else if ("GET".equalsIgnoreCase(s))          {return HTTP_GET;}
    else if ("HTTP_HEAD".equalsIgnoreCase(s))    {return HTTP_HEAD;}
    else if ("HEAD".equalsIgnoreCase(s))         {return HTTP_HEAD;}
    else if ("HTTP_POST".equalsIgnoreCase(s))    {return HTTP_POST;}
    else if ("POST".equalsIgnoreCase(s))         {return HTTP_POST;}
    else if ("HTTP_PUT".equalsIgnoreCase(s))     {return HTTP_PUT;}
    else if ("PUT".equalsIgnoreCase(s))          {return HTTP_PUT;}
    else if ("HTTP_PATCH".equalsIgnoreCase(s))   {return HTTP_PATCH;}
    else if ("PATCH".equalsIgnoreCase(s))        {return HTTP_PATCH;}
    else if ("HTTP_CONNECT".equalsIgnoreCase(s)) {return HTTP_CONNECT;}
    else if ("CONNECT".equalsIgnoreCase(s))      {return HTTP_CONNECT;}
    else if ("HTTP_OPTIONS".equalsIgnoreCase(s)) {return HTTP_OPTIONS;}
    else if ("OPTIONS".equalsIgnoreCase(s))      {return HTTP_OPTIONS;}
    else if ("HTTP_TRACE".equalsIgnoreCase(s))   {return HTTP_TRACE;}
    else if ("TRACE".equalsIgnoreCase(s))        {return HTTP_TRACE;}
    else if ("HTTP_COPY".equalsIgnoreCase(s))    {return HTTP_COPY;}
    else if ("COPY".equalsIgnoreCase(s))         {return HTTP_COPY;}
    else if ("HTTP_LOCK".equalsIgnoreCase(s))    {return HTTP_LOCK;}
    else if ("LOCK".equalsIgnoreCase(s))         {return HTTP_LOCK;}
    else if ("HTTP_MKCOL".equalsIgnoreCase(s))   {return HTTP_MKCOL;}
    else if ("MKCOL".equalsIgnoreCase(s))        {return HTTP_MKCOL;}
    else if ("HTTP_MOVE".equalsIgnoreCase(s))    {return HTTP_MOVE;}
    else if ("MOVE".equalsIgnoreCase(s))         {return HTTP_MOVE;}
    else if ("HTTP_PROPFIND".equalsIgnoreCase(s)){return HTTP_PROPFIND;}
    else if ("PROPFIND".equalsIgnoreCase(s))     {return HTTP_PROPFIND;}
    else if ("HTTP_PROPPATCH".equalsIgnoreCase(s)){return HTTP_PROPPATCH;}
    else if ("PROPPATCH".equalsIgnoreCase(s))    {return HTTP_PROPPATCH;}
    else if ("HTTP_UNLOCK".equalsIgnoreCase(s))  {return HTTP_UNLOCK;}
    else if ("UNLOCK".equalsIgnoreCase(s))       {return HTTP_UNLOCK;}
    else if ("HTTP_REPORT".equalsIgnoreCase(s)) {return HTTP_REPORT;}
    else if ("REPORT".equalsIgnoreCase(s)){return HTTP_REPORT;}
    else if ("HTTP_MKACTIVITY".equalsIgnoreCase(s)) {return HTTP_MKACTIVITY;}
    else if ("MKACTIVITY".equalsIgnoreCase(s)){return HTTP_MKACTIVITY;}
    else if ("HTTP_CHECKOUT".equalsIgnoreCase(s)) {return HTTP_CHECKOUT;}
    else if ("CHECKOUT".equalsIgnoreCase(s)){return HTTP_CHECKOUT;}
    else if ("HTTP_MERGE".equalsIgnoreCase(s)) {return HTTP_MERGE;}
    else if ("MERGE".equalsIgnoreCase(s)){return HTTP_MERGE;}
    else if ("HTTP_MSEARCH".equalsIgnoreCase(s))     {return HTTP_MSEARCH;}
    else if ("M-SEARCH".equalsIgnoreCase(s))         {return HTTP_MSEARCH;}
    else if ("HTTP_NOTIFY".equalsIgnoreCase(s))      {return HTTP_NOTIFY;}
    else if ("NOTIFY".equalsIgnoreCase(s))           {return HTTP_NOTIFY;}
    else if ("HTTP_SUBSCRIBE".equalsIgnoreCase(s))   {return HTTP_SUBSCRIBE;}
    else if ("SUBSCRIBE".equalsIgnoreCase(s))        {return HTTP_SUBSCRIBE;}
    else if ("HTTP_UNSUBSCRIBE".equalsIgnoreCase(s)) {return HTTP_UNSUBSCRIBE;}
    else if ("UNSUBSCRIBE".equalsIgnoreCase(s))      {return HTTP_UNSUBSCRIBE;}
    else if ("PATCH".equalsIgnoreCase(s))            {return HTTP_PATCH;}
    else if ("PURGE".equalsIgnoreCase(s))            {return HTTP_PURGE;}
	  else                                             {return null;}
	}
  void init (String name) {
    ASCII = null == ASCII ? Charset.forName("US-ASCII") : ASCII;
    this.bytes = name.getBytes(ASCII);
  }
}
