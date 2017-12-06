import React from 'react';
import PropTypes from 'prop-types';

export default class ColumnHeader extends React.PureComponent {

  static propTypes = {
    icon: PropTypes.string,
    type: PropTypes.string,
    active: PropTypes.bool,
    onClick: PropTypes.func,
    columnHeaderId: PropTypes.string,
  };

  handleClick = () => {
    this.props.onClick();
  }

  render () {
    const { type, active, columnHeaderId } = this.props;

    let icon = '';

    if (this.props.icon) {
      icon = <i className={`fa fa-fw fa-${this.props.icon} column-header__icon`} />;
    }

    return (
      <div role='heading' tabIndex='0' className={`column-header ${active ? 'active' : ''}`} onClick={this.handleClick} id={columnHeaderId || null}>
        {icon}
        {type}
      </div>
    );
  }

}
