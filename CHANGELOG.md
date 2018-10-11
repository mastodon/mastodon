## 2.5.2

- Fix XSS vulnerability (#8959)

## 2.5.1

- Fix some local images not having their EXIF metadata stripped on upload (#8714)
- Fix class autoloading issue in ActivityPub Create handler (#8820)
- Fix cache statistics not being sent via statsd when statsd enabled (#8831)
- Fix being able to enable a disabled relay via ActivityPub Accept handler (#8864)
- Bump nokogiri from 1.8.4 to 1.8.5 (#8881)
- Bump puma from 3.11.4 to 3.12.0 (#8883)
- Fix database migrations for PostgreSQL below 9.5 (#8903)
- Fix being able to report statuses not belonging to the reported account (#8916)
