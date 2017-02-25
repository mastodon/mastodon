Tuning Mastodon
===============

Mastodon has three types of processes:

- web
- streaming API
- background processing

By default, the web type spawns two worker processes with 5 threads each, the streaming API is a single thread/process with 10 database pool connections, and background processing spawns one process with 5 threads.

### Web

The web process serves short-lived HTTP requests for most of the application. The following environment variables control it:

- `WEB_CONCURRENCY` controls the number of worker processes
- `MAX_THREADS` controls the number of threads per process

The default is 2 workers with 5 threads each. Threads share the memory of their parent process. Different processes allocate their own memory each. Threads in Ruby are not native threads, so it's more or less: threads equal concurrency, processes equal parallelism. A larger number of threads maxes out your CPU first, a larger number of processes maxes out your RAM first.

These values affect how many HTTP requests can be served at the same time. When not enough threads are available, requests are queued until they can be answered.

For a single-user instance, 1 process with 5 threads should be more than enough.

### Streaming API

The streaming API handles long-lived HTTP and WebSockets connections, through which clients receive real-time updates. It is a single-threaded process. By default it has a database connection pool of 10, which means 10 different database queries can run *at the same time*. The database is not heavily used in the streaming API, only for initial authentication of the request, and for some special receiver-specific filter queries when receiving new messages. At the time of writing this value cannot be reconfigured, but mostly doesn't need to.

If you need to scale up the streaming API, spawn more separate processes on different ports (e.g. 4000, 4001, 4003, etc) and load-balance between them with nginx.

### Background processing

Many tasks in Mastodon are delegated to background processing to ensure the HTTP requests are fast, and to prevent HTTP request aborts from affecting the execution of those tasks. Sidekiq is a single process, with a configurable numbero of threads. By default, it is 5. That means, 5 different jobs can be executed at the same time. Others will be queued until they can be processed.

While the amount of threads in the web process affects the responsiveness of the Mastodon instance to the end-user, the amount of threads allocated to background processing affects how quickly posts can be delivered from the author to anyone else, how soon e-mails are sent out, etc.

The amount of threads is not controlled by an environment variable in this case, but a command line argument in the invocation of Sidekiq:

    bundle exec sidekiq -c 15 -q default -q mailers -q push

Would start the sidekiq process with 15 threads. Please mind that each threads needs to be able to connect to the database, which means that the database pool needs to be large enough to support all the threads. The database pool size is controlled with the `DB_POOL` environment variable, and defaults to the value of `MAX_THREADS` (therefore, is 5 by default).

You might notice that the above command specifies three queues to be processed:

- "default" contains most tasks such as delivering messages to followers and processing incoming notifications from other instances
- "mailers" contains tasks that send e-mails
- "push" contains tasks that deliver messages to other instances

If you wish, you could start three different processes for each queue, to ensure that even when there is a lot of tasks of one type, important tasks of other types still get executed in a timely manner.

___

### How to set environment variables
#### With systemd

In the `.service` file:

```systemd
...
Environment="WEB_CONCURRENCY=1"
Environment="MAX_THREADS=5"
ExecStart="..."
...
```

Don't forget to `sudo systemctl daemon-reload` before restarting the services so that the changes would take effect!

#### With docker-compose

Edit `docker-compose.yml`:

```yml
...
  web:
    restart: always
    build: .
    env_file: .env.production
    environment:
      - WEB_CONCURRENCY=1
      - MAX_THREADS=5
...
```

Re-create the containers with `docker-compose up -d` for the changes to take effect.

You can also scale the number of containers per "service" (where service is "web", "sidekiq" and "streaming"):

    docker-compose scale web=1 sidekiq=2 streaming=3

Realistically the `docker-compose.yml` file needs to be modified a bit further for the above to work, because by default it wants to bind the web container to host port 3000 and streaming container to host port 4000, of either of which there is only one on the host system. However, if you change:

```yml
ports:
  - "3000:3000"
```

to simply:

```yml
ports:
  - "3000"
```

for each service respectively, Docker will allocate random host ports of the services, allowing multiple containers to run alongside each other. But it will be on you to look up which host ports those are (e.g. with `docker ps`), and they will be different on each container restart.
