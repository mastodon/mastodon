# PgHero for Linux

Packaged for:

- Ubuntu 16.04 (Xenial)
- Ubuntu 14.04 (Trusty)
- Ubuntu 12.04 (Precise)
- Debian 7 (Wheezy)
- Debian 8 (Jesse)
- CentOS / RHEL 7
- SUSE Linux Enterprise Server 12

64-bit only

## Installation

Ubuntu 16.04 (Xenial)

```sh
wget -qO - https://deb.packager.io/key | sudo apt-key add -
echo "deb https://deb.packager.io/gh/pghero/pghero xenial master" | sudo tee /etc/apt/sources.list.d/pghero.list
sudo apt-get update
sudo apt-get -y install pghero
```

Ubuntu 14.04 (Trusty)

```sh
wget -qO - https://deb.packager.io/key | sudo apt-key add -
echo "deb https://deb.packager.io/gh/pghero/pghero trusty master" | sudo tee /etc/apt/sources.list.d/pghero.list
sudo apt-get update
sudo apt-get -y install pghero
```

Ubuntu 12.04 (Precise)

```sh
wget -qO - https://deb.packager.io/key | sudo apt-key add -
echo "deb https://deb.packager.io/gh/pghero/pghero precise master" | sudo tee /etc/apt/sources.list.d/pghero.list
sudo apt-get update
sudo apt-get -y install pghero
```

Debian 7 (Wheezy)

```sh
sudo apt-get -y install apt-transport-https
wget -qO - https://deb.packager.io/key | sudo apt-key add -
echo "deb https://deb.packager.io/gh/pghero/pghero wheezy master" | sudo tee /etc/apt/sources.list.d/pghero.list
sudo apt-get update
sudo apt-get -y install pghero
```

Debian 8 (Jesse)

```sh
sudo apt-get -y install apt-transport-https
wget -qO - https://deb.packager.io/key | sudo apt-key add -
echo "deb https://deb.packager.io/gh/pghero/pghero jessie master" | sudo tee /etc/apt/sources.list.d/pghero.list
sudo apt-get update
sudo apt-get -y install pghero
```

CentOS / RHEL 7

```sh
sudo rpm --import https://rpm.packager.io/key
echo "[pghero]
name=Repository for pghero/pghero application.
baseurl=https://rpm.packager.io/gh/pghero/pghero/centos7/master
enabled=1" | sudo tee /etc/yum.repos.d/pghero.repo
sudo yum -y install pghero
```

SUSE Linux Enterprise Server 12

```sh
sudo rpm --import https://rpm.packager.io/key
sudo zypper addrepo "https://rpm.packager.io/gh/pghero/pghero/sles12/master" "pghero"
sudo zypper install pghero
```

## Setup

Add your database.

```sh
sudo pghero config:set DATABASE_URL=postgres://user:password@hostname:5432/dbname
```

And optional authentication.

```sh
sudo pghero config:set PGHERO_USERNAME=link
sudo pghero config:set PGHERO_PASSWORD=hyrule
```

Start the server

```sh
sudo pghero config:set PORT=3001
sudo pghero config:set RAILS_LOG_TO_STDOUT=disabled
sudo pghero scale web=1
```

Confirm it’s running with:

```sh
curl -v http://localhost:3001/
```

To open to the outside world, add a proxy. Here’s how to do it with Nginx on Ubuntu.

```sh
sudo apt-get install -y nginx
cat | sudo tee /etc/nginx/sites-available/default <<EOF
server {
  listen          80;
  server_name     "";
  location / {
    proxy_pass    http://localhost:3001;
  }
}
EOF
sudo service nginx restart
```

## Management

```sh
sudo service pghero status
sudo service pghero start
sudo service pghero stop
sudo service pghero restart
```

View logs

```sh
sudo pghero logs
```

## Query Stats

Query stats can be enabled from the dashboard. If you run into issues, [view the guide](Query-Stats.md).

## Historical Query Stats

To track query stats over time, create a table to store them.

```sql
CREATE TABLE "pghero_query_stats" (
  "id" serial primary key,
  "database" text,
  "user" text,
  "query" text,
  "query_hash" bigint,
  "total_time" float,
  "calls" bigint,
  "captured_at" timestamp
)
CREATE INDEX ON "pghero_query_stats" ("database", "captured_at")
```

This table can be in the current database or another database. If another database, run:

```sh
sudo pghero config:set PGHERO_STATS_DATABASE_URL=...
```

Schedule the task below to run every 5 minutes.

```sh
sudo pghero run rake pghero:capture_query_stats
```

After this, a time range slider will appear on the Queries tab.

## System Stats

CPU usage is available for Amazon RDS.  Add these variables to your environment:

```sh
sudo pghero config:set PGHERO_ACCESS_KEY_ID=accesskey123
sudo pghero config:set PGHERO_SECRET_ACCESS_KEY=secret123
sudo pghero config:set PGHERO_DB_INSTANCE_IDENTIFIER=epona
```

## Multiple Databases

Create a `pghero.yml` with:

```yml
production:
  databases:
    primary:
      url: postgres://...
    replica:
      url: postgres://...
```

And run:

```sh
cat pghero.yml | sudo pghero run sh -c "cat > config/pghero.yml"
sudo service pghero restart
```

## Customize

Minimum time for long running queries

```sh
sudo pghero config:set PGHERO_LONG_RUNNING_QUERY_SEC=60 # default
```

Minimum average time for slow queries

```sh
sudo pghero config:set PGHERO_SLOW_QUERY_MS=20 # default
```

Minimum calls for slow queries

```sh
sudo pghero config:set PGHERO_SLOW_QUERY_CALLS=100 # default
```

Minimum connections for high connections warning

```sh
sudo pghero config:set PGHERO_TOTAL_CONNECTIONS_THRESHOLD=100 # default
```

## Upgrading

Ubuntu and Debian

```sh
sudo apt-get update
sudo apt-get install --only-upgrade pghero
```

CentOS and RHEL

```sh
sudo yum update
sudo yum install pghero
```

SUSE

```sh
sudo zypper update pghero
```

## Credits

:heart: Made possible by [Packager](https://packager.io/)
