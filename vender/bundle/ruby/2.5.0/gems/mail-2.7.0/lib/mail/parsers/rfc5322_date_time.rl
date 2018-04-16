%%{
  # RFC 5322 Internet Message Format
  # Section 3.3. Date and Time Specification
  # https://tools.ietf.org/html/rfc5322#section-3.3
  machine rfc5322_date_time;
  alphtype int;

  include rfc5322_lexical_tokens "rfc5322_lexical_tokens.rl";

  # day_of_week
  day_name = "Mon" | "Tue" | "Wed" | "Thu" | "Fri" | "Sat" | "Sun";
  obs_day_of_week = CFWS? day_name CFWS?;
  day_of_week = (FWS? day_name) | obs_day_of_week;

  # date
  obs_day = CFWS? (DIGIT | (DIGIT DIGIT)) CFWS?;
  day = (FWS? DIGIT DIGIT? FWS) | obs_day;
  month = "Jan" | "Feb" | "Mar" | "Apr" | "May" | "Jun" | "Jul" | "Aug" | "Sep" | "Oct" | "Nov" | "Dec";
  obs_year = CFWS? (DIGIT DIGIT DIGIT*) CFWS?;
  year = FWS DIGIT DIGIT DIGIT DIGIT FWS | obs_year;
  date = day month year;

  # time
  obs_hour = CFWS? (DIGIT DIGIT) CFWS?;
  hour = DIGIT DIGIT | obs_hour;
  obs_minute = CFWS? (DIGIT DIGIT) CFWS?;
  minute = DIGIT DIGIT | obs_minute;
  obs_second = CFWS? (DIGIT DIGIT) CFWS?;
  second = DIGIT DIGIT | obs_second;
  obs_zone = "UT" | "GMT" | "EST" | "EDT" | "CST" | "CDT" | "MST" | "MDT" | "PST" | "PDT" | 0x41..0x49 | 0x4B..0x5A | 0x61..0x69 | 0x6B..0x7A;
  time_of_day = hour ":" minute (":" second)?;
  zone = FWS ((("+" | "-") DIGIT DIGIT DIGIT DIGIT) | obs_zone);
  time = time_of_day zone;

  date_time = (day_of_week ",")?
              (date >date_s %date_e) <: (time >time_s %time_e) CFWS?;
}%%
