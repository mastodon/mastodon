Frontends and Skins
===================

**Mastodon** is a backend sever application and API, which users access through a combination of **frontends** and **skins**. The distinction between these is as follows:

- **skins** style Mastodon's static pages, such as its about page and settings pane. The default Mastodon skin is included in `/app/assets/skins/rooty`.
- **frontends** provide the user-experience when users are logged-in and interacting with the server. The default Mastodon frontend is designed using React/Redux and included in `/app/assets/frontends/tooty`.

##  Installing Skins/Frontends

Skins should be installed in the `/app/assets/skins` folder, and frontends should be installed in `/app/assets/frontends`.<sup>1</sup> You can then specify the skins and frontends you want Mastodon to use with environment variables, for example in `.env.production`. _**Right now,**_ if you don't specify anything for `SKIN` and `FRONTEND` it will default to `rooty` and `tooty`, respectively, but you _**should not**_ expect this to necessarily carry forward into the future. It is recommended you always explicitly declare the skin and frontend for your instance.

If you want to load multiple skins or frontends, you can separate these with pipes; for example:

```
SKIN=rooty|labcoat
FRONTEND=tooty|laboratory
```

However, by default mastodon will always pick the first of each.

<small>1. You can include them in other folders if you want, so long as there is exactly one directory between them and `/app/assets/`. However, using these folders is recommended.</small>

##  Creating Skins/Frontends

You can make your own skins and frontends for Mastodon! However, you should keep the following things in mind:

1. Your skin/frontend **must** include an `index.js` and `index.css` file (or something which compiles to these), as these are the files Mastodon will look for upon loading/precompiling. You can include as many other files from these as you like.

2. Right now, Mastodon loads its frontend with the line `= react_component 'Mastodon', default_props, class: 'app-holder', prerender: false` in `/app/views/home/index.html.haml`. This means that for the time being your frontend must be written using React, and its root component must be titled "Mastodon". (This may change in the future.)

3. It is *recommended* that your frontend/skin make use of SCSS variables and load `variables.scss` somewhere in its styling to allow easy user customization.

4. Skins and frontends **may not** share the same name. Otherwise, Mastodon wouldn't be able to tell which one to load!
