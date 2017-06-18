// Wrapper for IntersectionObserver in order to make working with it
// a bit easier. We also follow this performance advice:
// "If you need to observe multiple elements, it is both possible and
// advised to observe multiple elements using the same IntersectionObserver
// instance by calling observe() multiple times."
// https://developers.google.com/web/updates/2016/04/intersectionobserver

class IntersectionObserverWrapper {

  callbacks = {};
  observerBacklog = [];
  observer = null;

  connect (options) {
    const onIntersection = (entries) => {
      entries.forEach(entry => {
        const id = entry.target.getAttribute('data-id');
        if (this.callbacks[id]) {
          this.callbacks[id](entry);
        }
      });
    };

    this.observer = new IntersectionObserver(onIntersection, options);
    this.observerBacklog.forEach(([ id, node, callback ]) => {
      this.observe(id, node, callback);
    });
    this.observerBacklog = null;
  }

  observe (id, node, callback) {
    if (!this.observer) {
      this.observerBacklog.push([ id, node, callback ]);
    } else {
      this.callbacks[id] = callback;
      this.observer.observe(node);
    }
  }

  disconnect () {
    if (this.observer) {
      this.observer.disconnect();
    }
  }

}

export default IntersectionObserverWrapper;
