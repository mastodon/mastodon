%%{
  # RFC 3629 4. Syntax of UTF-8 Byte Sequences
  # https://tools.ietf.org/html/rfc3629#section-4
  machine rfc3629_utf8;
  alphtype int;

  utf8_tail  = 0x80..0xBF;

  utf8_2byte = 0xC2..0xDF utf8_tail;
  utf8_3byte = 0xE0       0xA0..0xBF  utf8_tail |
               0xE1..0xEC utf8_tail   utf8_tail |
               0xED       0x80..0x9F  utf8_tail |
               0xEE..0xEF utf8_tail   utf8_tail;
  utf8_4byte = 0xF0       0x90..0xBF  utf8_tail utf8_tail |
               0xF1..0xF3 utf8_tail   utf8_tail utf8_tail |
               0xF4       0x80..0x8F  utf8_tail utf8_tail;

  utf8_non_ascii = utf8_2byte | utf8_3byte | utf8_4byte;
}%%
