package http_parser;



import primitive.collection.ByteList;

public class ParserSettings extends http_parser.lolevel.ParserSettings {

  public HTTPCallback       on_message_begin;
  public HTTPDataCallback   on_path;
  public HTTPDataCallback   on_query_string;
  public HTTPDataCallback   on_url;
  public HTTPDataCallback   on_fragment;
  public HTTPCallback       on_status_complete;
  public HTTPDataCallback   on_header_field;
  public HTTPDataCallback   on_header_value;

  public HTTPCallback       on_headers_complete;
  public HTTPDataCallback   on_body;
  public HTTPCallback       on_message_complete;

  public HTTPErrorCallback  on_error;

  private HTTPCallback      _on_message_begin;
  private HTTPDataCallback  _on_path;
  private HTTPDataCallback  _on_query_string;
  private HTTPDataCallback  _on_url;
  private HTTPDataCallback  _on_fragment;
  private HTTPCallback      _on_status_complete;
  private HTTPDataCallback  _on_header_field;
  private HTTPDataCallback  _on_header_value;
  private HTTPCallback      _on_headers_complete;
  private HTTPDataCallback  _on_body;
  private HTTPCallback      _on_message_complete;
  private HTTPErrorCallback _on_error;

  private http_parser.lolevel.ParserSettings settings;

  protected ByteList field = new ByteList();
  protected ByteList value = new ByteList();
  protected ByteList body  = new ByteList();

  public ParserSettings() {
    this.settings = new http_parser.lolevel.ParserSettings();
    createMirrorCallbacks();
    attachCallbacks();
  }

  protected http_parser.lolevel.ParserSettings getLoLevelSettings() {
    return this.settings;
  }

  private void createMirrorCallbacks() {
    this._on_message_begin = new HTTPCallback() {
      public int cb(HTTPParser p) {
        if (null != ParserSettings.this.on_message_begin) {
          return ParserSettings.this.on_message_begin.cb(p);
        }
        return 0;
      }
    };
    this._on_path = new HTTPDataCallback() {
      @Override
      public int cb(HTTPParser p, byte[] by, int pos, int len) {
        if (null != ParserSettings.this.on_path) {
          return ParserSettings.this.on_path.cb(p, by, pos, len);
        }
        return 0;
      }
    };
    this._on_query_string = new HTTPDataCallback() {
      @Override
      public int cb(HTTPParser p, byte[] by, int pos, int len) {
        if (null != ParserSettings.this.on_query_string) {
          return ParserSettings.this.on_query_string.cb(p, by, pos, len);
        }
        return 0;
      }
    };
    this._on_url = new HTTPDataCallback() {
      @Override
      public int cb(HTTPParser p, byte[] by, int pos, int len) {
        if (null != ParserSettings.this.on_url) {
          return ParserSettings.this.on_url.cb(p, by, pos, len);
        }
        return 0;
      }
    };
    this._on_fragment = new HTTPDataCallback() {
      @Override
      public int cb(HTTPParser p, byte[] by, int pos, int len) {
        if (null != ParserSettings.this.on_fragment) {
          return ParserSettings.this.on_fragment.cb(p, by, pos, len);
        }
        return 0;
      }
    };
    this._on_status_complete = new HTTPCallback() {
      @Override
      public int cb(HTTPParser p) {
        if (null != ParserSettings.this.on_status_complete) {
          return ParserSettings.this.on_status_complete.cb(p);
        }
        return 0;
      }
    };
    this._on_error = new HTTPErrorCallback() {
      @Override
      public void cb(HTTPParser parser, String error) {
        if (null != ParserSettings.this.on_error) {
          ParserSettings.this.on_error.cb(parser, error);
        } else {
          throw new HTTPException(error);
        }

      }
    };



//    (on_header_field and on_header_value shortened to on_h_*)
//    ------------------------ ------------ --------------------------------------------
//   | State (prev. callback) | Callback   | Description/action                         |
//    ------------------------ ------------ --------------------------------------------
//   | nothing (first call)   | on_h_field | Allocate new buffer and copy callback data |
//   |                        |            | into it                                    |
//    ------------------------ ------------ --------------------------------------------
//   | value                  | on_h_field | New header started.                        |
//   |                        |            | Copy current name,value buffers to headers |
//   |                        |            | list and allocate new buffer for new name  |
//    ------------------------ ------------ --------------------------------------------
//   | field                  | on_h_field | Previous name continues. Reallocate name   |
//   |                        |            | buffer and append callback data to it      |
//    ------------------------ ------------ --------------------------------------------
//   | field                  | on_h_value | Value for current header started. Allocate |
//   |                        |            | new buffer and copy callback data to it    |
//    ------------------------ ------------ --------------------------------------------
//   | value                  | on_h_value | Value continues. Reallocate value buffer   |
//   |                        |            | and append callback data to it             |
//    ------------------------ ------------ --------------------------------------------
    this._on_header_field = new HTTPDataCallback() {
      @Override
      public int cb(HTTPParser p, byte[] by, int pos, int len) {
        // previous value complete, call on_value with full value, reset value.
        if (0 != ParserSettings.this.value.size()) {
          // check we're even interested...
          if (null != ParserSettings.this.on_header_value) {
            byte [] valueArr = ParserSettings.this.value.toArray();
            int ret = ParserSettings.this.on_header_value.cb(p, valueArr, 0, valueArr.length);
            if (0 != ret) {
              return ret;
            }
            ParserSettings.this.value.clear();
          }
        }

        if (null == ParserSettings.this.on_header_field) {
          return 0;
        }

        ParserSettings.this.field.addAll(by);
        return 0;
      }
    };
    this._on_header_value = new HTTPDataCallback() {
      @Override
      public int cb(HTTPParser p, byte[] by, int pos, int len) {

        // previous field complete, call on_field with full field value, reset field.
        if (0 != ParserSettings.this.field.size()) {
          // check we're even interested...
          if (null != ParserSettings.this.on_header_field) {
            byte [] fieldArr = ParserSettings.this.field.toArray();
            int ret = ParserSettings.this.on_header_field.cb(p, fieldArr, 0, fieldArr.length);
            if (0 != ret) {
              return ret;
            }
            ParserSettings.this.field.clear();
          }
        }

        if (null == ParserSettings.this.on_header_value) {
          return 0;
        }
        ParserSettings.this.value.addAll(by);
        return 0;
      }
    };
    this._on_headers_complete = new HTTPCallback() {
      @Override
      public int cb(HTTPParser parser) {
        // is there an uncompleted value ... ?
        if (0 != ParserSettings.this.value.size()) {
          // check we're even interested...
          if (null != ParserSettings.this.on_header_value) {
            byte [] valueArr = ParserSettings.this.value.toArray();
            int ret = ParserSettings.this.on_header_value.cb(parser, valueArr, 0, valueArr.length);
            if (0 != ret) {
              return ret;
            }
            ParserSettings.this.value.clear();
          }
        }
        if (null != ParserSettings.this.on_headers_complete) {
          return ParserSettings.this.on_headers_complete.cb(parser);
        }
        return 0;
      }

    };
    this._on_body = new HTTPDataCallback() {
      @Override
      public int cb(HTTPParser p, byte[] by, int pos, int len) {
        if (null != ParserSettings.this.on_body) {
          ParserSettings.this.body.addAll(by, pos, len);
        }
        return 0;
      }
    };

    this._on_message_complete = new HTTPCallback() {
      @Override
      public int cb(HTTPParser parser) {
        if (null != ParserSettings.this.on_body) {
          byte [] body = ParserSettings.this.body.toArray();
          int ret = ParserSettings.this.on_body.cb(parser, body, 0, body.length);
          if (0!=ret) {
            return ret;
          }
          ParserSettings.this.body.clear();
        }
        if (null != ParserSettings.this.on_message_complete) {
          return ParserSettings.this.on_message_complete.cb(parser);
        }
        return 0;
      }
    };

  }

  private void attachCallbacks() {
    // these are certainly set, because we mirror them ...
    this.settings.on_message_begin    = this._on_message_begin;
    this.settings.on_path             = this._on_path;
    this.settings.on_query_string     = this._on_query_string;
    this.settings.on_url              = this._on_url;
    this.settings.on_fragment         = this._on_fragment;
    this.settings.on_status_complete  = this._on_status_complete;
    this.settings.on_header_field     = this._on_header_field;
    this.settings.on_header_value     = this._on_header_value;
    this.settings.on_headers_complete = this._on_headers_complete;
    this.settings.on_body             = this._on_body;
    this.settings.on_message_complete = this._on_message_complete;
    this.settings.on_error            = this._on_error;
  }
}
