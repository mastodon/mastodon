import { JSDOM } from 'jsdom';
import chai from 'chai';
import chaiEnzyme from 'chai-enzyme';
chai.use(chaiEnzyme());

const { window } = new JSDOM('', {
  userAgent: 'node.js',
});
Object.keys(window).forEach(property => {
  if (typeof global[property] === 'undefined') {
    global[property] = window[property];
  }
});
