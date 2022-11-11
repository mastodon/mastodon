import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';

export default class Icon extends React.PureComponent {

  static propTypes = {
    id: PropTypes.string.isRequired,
    className: PropTypes.string,
    fixedWidth: PropTypes.bool,
    decorative: PropTypes.bool,
  };

  render () {
    const { id, className, fixedWidth, decorative, ...other } = this.props;

    return (
      <i role={decorative ? undefined : 'img'} className={classNames('fa', `fa-${id}`, className, { 'fa-fw': fixedWidth })} alt={decorative ? undefined : id} {...other} />
    );
  }

}
