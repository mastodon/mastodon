import React from 'react';
import PropTypes from 'prop-types';
import outlets from '../outlets';

export default class Outlet extends React.PureComponent {

  static propTypes = {
    name: PropTypes.string,
  };

  render () {
    const { name } = this.props;
    return outlets[name].map((outlet) => React.createElement(outlet.component, outlet.props));
  }

}
