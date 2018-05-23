# Restarts

To perform a restart, there are 3 builtin mechanisms:

  * Send the `puma` process the `SIGUSR2` signal
  * Send the `puma` process the `SIGUSR1` signal (rolling restart, cluster mode only)
  * Use the status server and issue `/restart`

No code is shared between the current and restarted process, so it should be safe to issue a restart any place where you would manually stop Puma and start it again.

If the new process is unable to load, it will simply exit. You should therefore run Puma under a process monitor (see below) when using it in production.

### Normal vs Hot vs Phased Restart

A hot restart means that no requests will be lost while deploying your new code, since the server socket is kept open between restarts.

But beware, hot restart does not mean that the incoming requests won’t hang for multiple seconds while your new code has not fully deployed. If you need a zero downtime and zero hanging requests deploy, you must use phased restart.

When you run pumactl phased-restart, Puma kills workers one-by-one, meaning that at least another worker is still available to serve requests, which lead to zero hanging requests (yay!).

But again beware, upgrading an application sometimes involves upgrading the database schema. With phased restart, there may be a moment during the deployment where processes belonging to the previous version and processes belonging to the new version both exist at the same time. Any database schema upgrades you perform must therefore be backwards-compatible with the old application version.

If you perform a lot of database migrations, you probably should not use phased restart and use a normal/hot restart instead (pumactl restart). That way, no code is shared while deploying (in that case, preload_app might help for quicker deployment, see below).

### Release Directory

If your symlink releases into a common working directory (i.e., `/current` from Capistrano), Puma won't pick up your new changes when running phased restarts without additional configuration. You should set your working directory within Puma's config to specify the directory it should use. This is a change from earlier versions of Puma (< 2.15) that would infer the directory for you.

```ruby
# config/puma.rb

directory '/var/www/current'
```

### Cleanup Code

Puma isn't able to understand all the resources that your app may use, so it provides a hook in the configuration file you pass to `-C` called `on_restart`. The block passed to `on_restart` will be called, unsurprisingly, just before Puma restarts itself.

You should place code to close global log files, redis connections, etc. in this block so that their file descriptors don't leak into the restarted process. Failure to do so will result in slowly running out of descriptors and eventually obscure crashes as the server is restarted many times.
