import asyncDB from './db';
import { autoPlayGif } from '../initial_state';

const accountAssetKeys = ['avatar', 'avatar_static', 'header', 'header_static'];
const avatarKey = autoPlayGif ? 'avatar' : 'avatar_static';
const limit = 1024;

// ServiceWorker and Cache API is not available on iOS 11
// https://webkit.org/status/#specification-service-workers
const asyncCache = window.caches ? caches.open('mastodon-system') : Promise.reject();

function put(name, objects, onupdate, oncreate) {
  return asyncDB.then(db => new Promise((resolve, reject) => {
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
        const excess = count.result - limit;

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
  }));
}

function evictAccountsByRecords(records) {
  asyncDB.then(db => {
    const transaction = db.transaction(['accounts', 'statuses'], 'readwrite');
    const accounts = transaction.objectStore('accounts');
    const accountsIdIndex = accounts.index('id');
    const accountsMovedIndex = accounts.index('moved');
    const statuses = transaction.objectStore('statuses');
    const statusesIndex = statuses.index('account');

    function evict(toEvict) {
      toEvict.forEach(record => {
        asyncCache.then(cache => accountAssetKeys.forEach(key => cache.delete(records[key])));

        accountsMovedIndex.getAll(record.id).onsuccess = ({ target }) => evict(target.result);

        statusesIndex.getAll(record.id).onsuccess =
          ({ target }) => evictStatusesByRecords(target.result);

        accountsIdIndex.getKey(record.id).onsuccess =
          ({ target }) => target.result && accounts.delete(target.result);
      });
    }

    evict(records);
  });
}

export function evictStatus(id) {
  return evictStatuses([id]);
}

export function evictStatuses(ids) {
  asyncDB.then(db => {
    const store = db.transaction('statuses', 'readwrite').objectStore('statuses');
    const idIndex = store.index('id');
    const reblogIndex = store.index('reblog');

    ids.forEach(id => {
      reblogIndex.getAllKeys(id).onsuccess =
        ({ target }) => target.result.forEach(reblogKey => store.delete(reblogKey));

      idIndex.getKey(id).onsuccess =
        ({ target }) => target.result && store.delete(target.result);
    });
  });
}

function evictStatusesByRecords(records) {
  evictStatuses(records.map(({ id }) => id));
}

export function putAccounts(records) {
  const newURLs = [];

  put('accounts', records, (newRecord, oldKey, store, oncomplete) => {
    store.get(oldKey).onsuccess = ({ target }) => {
      accountAssetKeys.forEach(key => {
        const newURL = newRecord[key];
        const oldURL = target.result[key];

        if (newURL !== oldURL) {
          asyncCache.then(cache => cache.delete(oldURL));
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
  }).then(records => {
    evictAccountsByRecords(records);
    asyncCache.then(cache => cache.addAll(newURLs));
  });
}

export function putStatuses(records) {
  put('statuses', records).then(evictStatusesByRecords);
}
