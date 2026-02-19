Files in this directory are Material Symbols icons fetched using the `icons:download` rake task (see `/lib/tasks/icons.rake`).

To add another icon, follow these steps:

- Determine the name of the Material Symbols icon you want to download.
  You can find a searchable overview of all icons on [https://fonts.google.com/icons].
  Click on the icon you want to use and find the icon name towards the bottom of the slide-out panel (it'll be something like `icon_name`)
- Import the icon in your React component using the following format:
  `import IconName from '@/material-icons/400-24px/icon_name.svg?react';`
- Run `RAILS_ENV=development rails icons:download` to download any newly imported icons.

The import should now work and the icon should appear when passed to the `<Icon icon={IconName} /> component
