import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';

export default class Icon extends React.PureComponent {

  static propTypes = {
    id: PropTypes.string.isRequired,
    className: PropTypes.string,
    fixedWidth: PropTypes.bool,
  };

  render () {
    const { id, className, fixedWidth, ...other } = this.props;

    const key = ['fab', 'fas', 'far', 'fal', 'fad'];

    let fa = 'fa',
        tag = id;
    if (id.includes(':')) {
      key.forEach(key => {
        if (id.includes(`:${key}`)) {
          fa = key;
          tag = id.replace(`:${key}`, '');
          return false;
        }
      })
    }

    return (
      <i role='img' className={classNames(fa, `fa-${tag}`, className, { 'fa-fw': fixedWidth })} {...other} />
    );
  }

}
