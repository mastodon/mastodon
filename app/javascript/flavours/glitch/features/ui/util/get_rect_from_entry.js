
// Get the bounding client rect from an IntersectionObserver entry.
// This is to work around a bug in Chrome: https://crbug.com/737228

let hasBoundingRectBug;

function getRectFromEntry(entry) {
  if (typeof hasBoundingRectBug !== 'boolean') {
    const boundingRect = entry.target.getBoundingClientRect();
    const observerRect = entry.boundingClientRect;
    hasBoundingRectBug = boundingRect.height !== observerRect.height ||
      boundingRect.top !== observerRect.top ||
      boundingRect.width !== observerRect.width ||
      boundingRect.bottom !== observerRect.bottom ||
      boundingRect.left !== observerRect.left ||
      boundingRect.right !== observerRect.right;
  }
  return hasBoundingRectBug ? entry.target.getBoundingClientRect() : entry.boundingClientRect;
}

export default getRectFromEntry;
