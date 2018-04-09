export default () => new Promise((resolve, reject) => {
  // ServiceWorker is required to synchronize the login state.
  // Microsoft Edge 17 does not support getAll according to:
  // Catalog of standard and vendor APIs across browsers - Microsoft Edge Development
  // https://developer.microsoft.com/en-us/microsoft-edge/platform/catalog/?q=specName%3Aindexeddb
  if (!('caches' in self && 'getAll' in IDBObjectStore.prototype)) {
    reject();
    return;
  }

  const request = indexedDB.open('mastodon');

  request.onerror = reject;
  request.onsuccess = ({ target }) => resolve(target.result);

  request.onupgradeneeded = ({ target }) => {
    const accounts = target.result.createObjectStore('accounts', { autoIncrement: true });
    const statuses = target.result.createObjectStore('statuses', { autoIncrement: true });

    accounts.createIndex('id', 'id', { unique: true });
    accounts.createIndex('moved', 'moved');

    statuses.createIndex('id', 'id', { unique: true });
    statuses.createIndex('account', 'account');
    statuses.createIndex('reblog', 'reblog');
  };
});
