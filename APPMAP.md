# AppMap

=======

This installation of Mastodon has been customized with [AppMap](https://appland.com) and is a recommended extension for this repo.

This is used primarily to create the [openapi.yml][/openapi.yml] file.

See [Installing AppMap in Mastodon With VS Code](https://dev.to/appmap/installing-appmap-in-mastodon-with-vs-code-167d) for more details.

Running this via VS Code is recommended.

## Startup

Run as a local machine devcontainer via Docker.

Run `bundle exec rails server` on devcontainer startup, after installing AppMap. When the server starts up it will run via AppMap and start logging requests.

Edit `config/webpacker.yml` under the `test` section and *temporarily* change `compile: false` to `compile: true`. Run `RAILS_ENV=test ./bin/webpack` to generate assets for the tests. Once this is complete, change compile back to false in the webpacker.yml file.

Try running `RAILS_ENV=test bundle exec rspec spec/controllers/settings/applications_controller_spec.rb` first to confirm a single test works.

Run `RAILS_ENV=test bundle exec rspec` to execute all the tests. This will take as long as an hour to complete.

Run `npx @appland/appmap@latest openapi --output-file openapi.yml --openapi-title Mastodon` to generate openapi.yml docs.
