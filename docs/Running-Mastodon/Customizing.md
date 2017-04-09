Customizing your instance
=========================

## Customizing style

If you create `app/assets/stylesheets/custom.scss`, the default css will be replaced by the content in `custom.scss`.

## Changing colors

If you want to customize for example the vibrant color of your mastodon instance, you can put the following code in your
`custom.scss` file :

````scss
$color4: #d3d900; // vibrant

@import 'application';
````

Don't forget to recompile your assets and restart mastodon(if you didn't have a `custom.scss` file before) 
to see the changes.