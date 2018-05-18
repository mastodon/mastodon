import openDB from './db';

const accountAssetKeys = ['avatar', 'avatar_static', 'header', 'header_static'];
const storageMargin = 8388608;
const storeLimit = 1024;

function openCache() {
  // ServiceWorker and Cache API is not available on iOS 11
  // https://webkit.org/status/#specification-service-workers
  return self.caches ? caches.open('mastodon-system') : Promise.reject();
}

function printErrorIfAvailable(error) {
  if (error) {
    console.warn(error);
  }
}

function put(name, objects, onupdate, oncreate) {
  return openDB().then(db => (new Promise((resolve, reject) => {
    const putTransaction = db.transaction(name, 'readwrite');
    const putStore = putTransaction.objectStore(name);
    const putIndex = putStore.index('id');

    objects.forEach(object => {
      putIndex.getKey(object.id).onsuccess = retrieval => {
        function addObject() {
          putStore.add(object);
        }

        function deleteObject() {
          putStore.delete(retrieval.target.result).onsuccess = addObject;
        }

        if (retrieval.target.result) {
          if (onupdate) {
            onupdate(object, retrieval.target.result, putStore, deleteObject);
          } else {
            deleteObject();
          }
        } else {
          if (oncreate) {
            oncreate(object, addObject);
          } else {
            addObject();
          }
        }
      };
    });

    putTransaction.oncomplete = () => {
      const readTransaction = db.transaction(name, 'readonly');
      const readStore = readTransaction.objectStore(name);
      const count = readStore.count();

      count.onsuccess = () => {
        const excess = count.result - storeLimit;

        if (excess > 0) {
          const retrieval = readStore.getAll(null, excess);

          retrieval.onsuccess = () => resolve(retrieval.result);
          retrieval.onerror = reject;
        } else {
          resolve([]);
        }
      };

      count.onerror = reject;
    };

    putTransaction.onerror = reject;
  })).then(resolved => {
    db.close();
    return resolved;
  }, error => {
    db.close();
    throw error;
  }));
}

function evictAccountsByRecords(records) {
  return openDB().then(db => {
    const transaction = db.transaction(['accounts', 'statuses'], 'readwrite');
    const accounts = transaction.objectStore('accounts');
    const accountsIdIndex = accounts.index('id');
    const accountsMovedIndex = accounts.index('moved');
    const statuses = transaction.objectStore('statuses');
    const statusesIndex = statuses.index('account');

    function evict(toEvict) {
      toEvict.forEach(record => {
        openCache()
          .then(cache => accountAssetKeys.forEach(key => cache.delete(records[key])))
          .catch(printErrorIfAvailable);

        accountsMovedIndex.getAll(record.id).onsuccess = ({ target }) => evict(target.result);

        statusesIndex.getAll(record.id).onsuccess =
          ({ target }) => evictStatusesByRecords(target.result);

        accountsIdIndex.getKey(record.id).onsuccess =
          ({ target }) => target.result && accounts.delete(target.result);
      });
    }

    evict(records);

    db.close();
  }).catch(printErrorIfAvailable);
}

export function evictStatus(id) {
  evictStatuses([id]);
}

export function evictStatuses(ids) {
  return openDB().then(db => {
    const transaction = db.transaction('statuses', 'readwrite');
    const store = transaction.objectStore('statuses');
    const idIndex = store.index('id');
    const reblogIndex = store.index('reblog');

    ids.forEach(id => {
      reblogIndex.getAllKeys(id).onsuccess =
        ({ target }) => target.result.forEach(reblogKey => store.delete(reblogKey));

      idIndex.getKey(id).onsuccess =
        ({ target }) => target.result && store.delete(target.result);
    });

    db.close();
  }).catch(printErrorIfAvailable);
}

function evictStatusesByRecords(records) {
  return evictStatuses(records.map(({ id }) => id));
}

export function putAccounts(records, avatarStatic) {
  const avatarKey = avatarStatic ? 'avatar_static' : 'avatar';
  const newURLs = [];

  put('accounts', records, (newRecord, oldKey, store, oncomplete) => {
    store.get(oldKey).onsuccess = ({ target }) => {
      accountAssetKeys.forEach(key => {
        const newURL = newRecord[key];
        const oldURL = target.result[key];

        if (newURL !== oldURL) {
          openCache()
            .then(cache => cache.delete(oldURL))
            .catch(printErrorIfAvailable);
        }
      });

      const newURL = newRecord[avatarKey];
      const oldURL = target.result[avatarKey];

      if (newURL !== oldURL) {
        newURLs.push(newURL);
      }

      oncomplete();
    };
  }, (newRecord, oncomplete) => {
    newURLs.push(newRecord[avatarKey]);
    oncomplete();
  }).then(records => Promise.all([
    evictAccountsByRecords(records),
    openCache().then(cache => cache.addAll(newURLs)),
  ])).then(freeStorage, error => {
    freeStorage();
    throw error;
  }).catch(printErrorIfAvailable);
}

export function putStatuses(records) {
  put('statuses', records)
    .then(evictStatusesByRecords)
    .catch(printErrorIfAvailable);
}

export function freeStorage() {
  // navigator.storage is not present on:
  // Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.100 Safari/537.36 Edge/16.16299
  // estimate method is not present on Chrome 57.0.2987.98 on Linux.
  return 'storage' in navigator && 'estimate' in navigator.storage && navigator.storage.estimate().then(({ quota, usage }) => {
    if (usage + storageMargin < quota) {
      return null;
    }

    return openDB().then(db => new Promise((resolve, reject) => {
      const retrieval = db.transaction('accounts', 'readonly').objectStore('accounts').getAll(null, 1);

      retrieval.onsuccess = () => {
        if (retrieval.result.length > 0) {
          resolve(evictAccountsByRecords(retrieval.result).then(freeStorage));
        } else {
          resolve(caches.delete('mastodon-system'));
        }
      };

      retrieval.onerror = reject;

      db.close();
    }));
  });
}
