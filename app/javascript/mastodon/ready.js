// @ts-check

/**
 * @param {(() => void) | (() => Promise<void>)} callback
 * @returns {Promise<void>}
 */
export default function ready(callback) {
  return new Promise((resolve, reject) => {
    function loaded() {
      let result;
      try {
        result = callback();
      } catch (err) {
        reject(err);

        return;
      }

      if (typeof result?.then === 'function') {
        result.then(resolve).catch(reject);
      } else {
        resolve();
      }
    }

    if (['interactive', 'complete'].includes(document.readyState)) {
      loaded();
    } else {
      document.addEventListener('DOMContentLoaded', loaded);
    }
  });
}
