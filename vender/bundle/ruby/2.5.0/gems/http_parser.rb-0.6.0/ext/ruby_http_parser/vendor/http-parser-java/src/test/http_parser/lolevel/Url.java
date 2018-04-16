package http_parser.lolevel;

import http_parser.FieldData;
import http_parser.HTTPParserUrl;

import static http_parser.HTTPParserUrl.*;
import static http_parser.lolevel.HTTPParser.*;

/**
 */
public class Url {
  
  public static Url[] URL_TESTS = new Url[]{
      new Url("proxy request", "http://hostname/", false,
          new HTTPParserUrl(
              (1 << UrlFields.UF_SCHEMA.getIndex()) | (1 << UrlFields.UF_HOST.getIndex()) | (1 << UrlFields.UF_PATH.getIndex()),
              0,
              new FieldData[]{
                  new FieldData(0,4),
                  new FieldData(7,8),
                  new FieldData(0,0),
                  new FieldData(15,1),
                  new FieldData(0,0),
                  new FieldData(0,0)
              }),
          0),
      new Url("CONNECT request", "hostname:443", true,
          new HTTPParserUrl(
              (1 << UrlFields.UF_HOST.getIndex()) | (1 << UrlFields.UF_PORT.getIndex()),
              443,
              new FieldData[]{
                  new FieldData(0,0),
                  new FieldData(0,8),
                  new FieldData(9,3),
                  new FieldData(0,0),
                  new FieldData(0,0),
                  new FieldData(0,0)
              }),
          0),
      new Url("proxy ipv6 request", "http://[1:2::3:4]/", false,
          new HTTPParserUrl(
              (1 << UrlFields.UF_SCHEMA.getIndex()) | (1 << UrlFields.UF_HOST.getIndex()) | (1 << UrlFields.UF_PATH.getIndex()),
              0,
              new FieldData[]{
                  new FieldData(0,4),
                  new FieldData(8,8),
                  new FieldData(0,0),
                  new FieldData(17,1),
                  new FieldData(0,0),
                  new FieldData(0,0)
              }),
          0),
      new Url("CONNECT ipv6 address", "[1:2::3:4]:443", true,
          new HTTPParserUrl(
              (1 << UrlFields.UF_HOST.getIndex()) | (1 << UrlFields.UF_PORT.getIndex()),
              443,
              new FieldData[]{
                  new FieldData(0,0),
                  new FieldData(1,8),
                  new FieldData(11,3),
                  new FieldData(0,0),
                  new FieldData(0,0),
                  new FieldData(0,0)
              }),
          0),
      new Url("extra ? in query string",
          "http://a.tbcdn.cn/p/fp/2010c/??fp-header-min.css,fp-base-min.css,fp-channel-min.css,fp-product-min.css,fp-mall-min.css,fp-category-min.css,fp-sub-min.css,fp-gdp4p-min.css,fp-css3-min.css,fp-misc-min.css?t=20101022.css",
          false,
          new HTTPParserUrl(
              (1 << UrlFields.UF_SCHEMA.getIndex()) |
              (1 << UrlFields.UF_HOST.getIndex()) |
              (1 << UrlFields.UF_PATH.getIndex()) |
              (1 << UrlFields.UF_QUERY.getIndex()),
              0,
              new FieldData[]{
                  new FieldData(0,4),
                  new FieldData(7,10),
                  new FieldData(0,0),
                  new FieldData(17,12),
                  new FieldData(30,187),
                  new FieldData(0,0)
              }),
          0),
      new Url("proxy empty host",
          "http://:443/",
          false,
          null,
          1),
      new Url("proxy empty port",
          "http://hostname:/",
          false,
          null,
          1),
      new Url("CONNECT empty host",
          ":443",
          true,
          null,
          1),
      new Url("CONNECT empty port",
          "hostname:",
          true,
          null,
          1),
      new Url("CONNECT with extra bits",
          "hostname:443/",
          true,
          null,
          1),

  };

  String name;
  String url;
  boolean is_connect;
  HTTPParserUrl u;
  int rv;
  
  public Url(String name, String url, boolean is_connect, HTTPParserUrl u, int rv) {
    this.name = name;
    this.url = url;
    this.is_connect = is_connect;
    this.u = u;
    this.rv = rv;
  }


}
