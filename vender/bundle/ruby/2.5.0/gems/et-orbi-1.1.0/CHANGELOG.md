
# et-orbi CHANGELOG.md


## et-orbi 1.1.0  released 2018-03-25

- Implement EoTime .utc and .local (based on Time .utc and .local)
- Add EoTime#translate(target_zone) as #localtime(target_zone) alias
- Correct EoTime#iso8601 (was always returning zulu iso8601 string)


## et-orbi 1.0.9  released 2018-01-19

- Silence EoTime#strfz warning
- Silence warnings reported by @mdave16, gh-10
- @philr added support for upcoming tzinfo 2.x, gh-9


## et-orbi 1.0.8  released 2017-10-24

- Ensure ::EoTime.new accepts ActiveSupport::TimeZone, closes gh-8


## et-orbi 1.0.7  released 2017-10-07

- Leverage ActiveSupport::TimeWithZone when present, gh-6
- Start error messages with a capital


## et-orbi 1.0.6  released 2017-10-05

- Introduce `make info`
- Alias EoTime#to_utc_time to #utc
- Alias EoTime#to_t to #to_local_time
- Implement EoTime#to_local_time (since #to_time returns a UTC Time instance)


## et-orbi 1.0.5  released 2017-06-23

- Rework EtOrbi.make_time
- Let EtOrbi.make_time accept array or array of args
- Implement EoTime#localtime(zone=nil)
- Move Fugit#wday_in_month into EoTime
- Clarify #add, #subtract, #- and #+ contracts
- Ensure #add and #subtract return `self`
- Make #inc(seconds, direction) public
- Implement EoTime#utc?


## et-orbi 1.0.4  released 2017-05-10

- Survive older versions of TZInfo with poor `<=>` impl, gh-1


## et-orbi 1.0.3  released 2017-04-07

- Let not #render_nozone_time fail when local_tzone is nil


## et-orbi 1.0.2  released 2017-03-24

- Enhance no zone ArgumentError data
- Separate module methods from EoTime methods


## et-orbi 1.0.1  released 2017-03-22

- Detail Rails and Active Support info in nozone err


## et-orbi 1.0.0  released 2017-03-22

- First release for rufus-scheduler


## et-orbi 0.9.5  released 2017-03-17

- Empty, initial release, 圓さんの家で

