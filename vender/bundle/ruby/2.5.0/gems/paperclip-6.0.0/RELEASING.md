Releasing paperclip

1. Update `lib/paperclip/version.rb` file accordingly.
2. Update `NEWS` to reflect the changes since last release.
3. Commit changes. There shouldn’t be code changes, and thus CI doesn’t need to
   run, you can then add “[ci skip]” to the commit message.
4. Tag the release: `git tag -m 'vVERSION' vVERSION`
5. Push changes: `git push --tags`
6. Build and publish the gem:

   ```bash
   gem build paperclip.gemspec
   gem push paperclip-VERSION.gem
   ```

7. Announce the new release, making sure to say “thank you” to the contributors
   who helped shape this version.
