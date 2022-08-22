export default function uuid(a) {
  return a ? (a ^ (crypto.getRandomValues(new Uint32Array(1))[0] / 0xffffffff) * 16 >> a / 4).toString(16) : ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, uuid);
};
