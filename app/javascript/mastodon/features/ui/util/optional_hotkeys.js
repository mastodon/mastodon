// Hot keys are an optional feature, so only load them if the
// body class "use-hotkeys" exists. We use the body class rather than
// the Redux store because the value never changes without a page reload,
// so we can just check once and load HotKeys once.

import { HotKeys as HotKeysAsync } from './async-components';
import ready from '../../../ready';
import React from 'react';
import PropTypes from 'prop-types';

let HotKeys;

class NoHotKeys extends React.Component {

  static propTypes = {
    children: PropTypes.node,
  }

  render() {
    return (<div>{this.props.children}</div>);
  }

}

export function loadHotKeys() {
  return new Promise(resolve => ready(resolve)).then(() => {
    if (document.body.classList.contains('use-hotkeys')) {
      return HotKeysAsync().then(TheHotKeys => {
        HotKeys = TheHotKeys.default;
      });
    } else {
      HotKeys = NoHotKeys;
      return Promise.resolve();
    }
  });
}

export function getHotKeys() {
  return HotKeys;
}
