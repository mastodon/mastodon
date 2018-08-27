// global animation loop for all VelocityScroller instances

const animationLoopItems = {};
let lastAnimationTime = null;
let loopIsRunning = false;

function animationLoop () {
  const keysMarkedForRemoval = [];
  const now = Date.now();
  const deltaTime = (now - lastAnimationTime) / 1000;
  lastAnimationTime = now;
  let isEmptyLoop = true;

  for (const key in animationLoopItems) {
    const item = animationLoopItems[key];

    if (!item(deltaTime)) keysMarkedForRemoval.push(key);

    isEmptyLoop = false;
  }

  for (const key of keysMarkedForRemoval) {
    delete animationLoopItems[key];
  }

  if (isEmptyLoop) {
    loopIsRunning = false;
  } else {
    window.requestAnimationFrame(animationLoop);
  }
}

function startAnimationLoop () {
  if (!loopIsRunning) {
    loopIsRunning = true;
    lastAnimationTime = Date.now();
    animationLoop();
  }
}

function addAnimation (id, fn) {
  animationLoopItems[id] = fn;
  startAnimationLoop();
}

function removeAnimation (id) {
  delete animationLoopItems[id];
}

let animationIDCounter = 0;

// A velocity scroller; basically a spring with no restoring force.
export default class VelocityScroller {

  constructor (damping, initialPosition = 0) {
    this.position = initialPosition;
    this.velocity = 0;
    this.damping = damping;
    this.tolerance = 1 / 1000;
    this.onUpdate = () => {};

    this.scrollerID = (++animationIDCounter).toString();
  }

  start () {
    addAnimation(this.scrollerID, this.update);
  }

  stop () {
    removeAnimation(this.scrollerID);
  }

  update = (deltaTime) => {
    if (deltaTime > 1 / 30) {
      // clamp to prevent exponential badness
      deltaTime = 1 / 30;
    }

    const force = this.currentForce();
    const deltaPosition = force * deltaTime;
    this.velocity += deltaPosition;
    this.position += this.velocity * deltaTime;

    this.onUpdate(this.position, deltaPosition);

    return this.needsUpdate();
  }

  currentForce () {
    return -this.damping * this.velocity;
  }

  needsUpdate () {
    return Math.abs(this.velocity) > this.tolerance;
  }

}
