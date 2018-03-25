import asyncDB from './async';

const limit = 1024;

function put(name, objects, callback) {
  asyncDB.then(db => {
    const putTransaction = db.transaction(name, 'readwrite');
    const putStore = putTransaction.objectStore(name);
    const putIndex = putStore.index('id');

    objects.forEach(object => {
      function add() {
        putStore.add(object);
      }

      putIndex.getKey(object.id).onsuccess = retrieval => {
        if (retrieval.target.result) {
          putStore.delete(retrieval.target.result).onsuccess = add;
        } else {
          add();
        }
      };
    });

    putTransaction.oncomplete = () => {
      const readTransaction = db.transaction(name, 'readonly');
      const readStore = readTransaction.objectStore(name);

      readStore.count().onsuccess = count => {
        const excess = count.target.result - limit;

        if (excess > 0) {
          readStore.getAll(null, excess).onsuccess =
            retrieval => callback(retrieval.target.result.map(({ id }) => id));
        }
      };
    };
  });
}

export function evictAccounts(ids) {
  asyncDB.then(db => {
    const transaction = db.transaction(['accounts', 'statuses'], 'readwrite');
    const accounts = transaction.objectStore('accounts');
    const accountsIdIndex = accounts.index('id');
    const accountsMovedIndex = accounts.index('moved');
    const statuses = transaction.objectStore('statuses');
    const statusesIndex = statuses.index('account');

    function evict(toEvict) {
      toEvict.forEach(id => {
        accountsMovedIndex.getAllKeys(id).onsuccess =
          ({ target }) => evict(target.result);

        statusesIndex.getAll(id).onsuccess =
          ({ target }) => evictStatuses(target.result.map(({ id }) => id));

        accountsIdIndex.getKey(id).onsuccess =
          ({ target }) => target.result && accounts.delete(target.result);
      });
    }

    evict(ids);
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

export function putAccounts(records) {
  put('accounts', records, evictAccounts);
}

export function putStatuses(records) {
  put('statuses', records, evictStatuses);
}
