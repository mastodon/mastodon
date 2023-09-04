/* @preval */

const fs   = require('fs');
const path = require('path');

const filtered  = {};
const filenames = fs.readdirSync(path.resolve(__dirname, '../locales'));

filenames.forEach(filename => {
  if (!filename.match(/\.json$/) || filename.match(/defaultMessages|whitelist/)) return;

  const content = fs.readFileSync(path.resolve(__dirname, `../locales/${filename}`), 'utf-8');
  const full    = JSON.parse(content);
  const locale  = filename.split('.')[0];

  filtered[locale] = {
    'notification.favourite': full['notification.favourite'] || '',
    'notification.follow': full['notification.follow'] || '',
    'notification.follow_request': full['notification.follow_request'] || '',
    'notification.mention': full['notification.mention'] || '',
    'notification.reblog': full['notification.reblog'] || '',
    'notification.poll': full['notification.poll'] || '',
    'notification.status': full['notification.status'] || '',
    'notification.update': full['notification.update'] || '',
    'notification.admin.sign_up': full['notification.admin.sign_up'] || '',

    'status.show_more': full['status.show_more'] || '',
    'status.reblog': full['status.reblog'] || '',
    'status.favourite': full['status.favourite'] || '',

    'notifications.group': full['notifications.group'] || '',
  };
});

module.exports = JSON.parse(JSON.stringify(filtered));
