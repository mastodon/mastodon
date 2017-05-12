import React from 'react';
import PropTypes from 'prop-types'

class ColumnHeader extends React.PureComponent {

  static propTypes = {
    icon: PropTypes.string,
    type: PropTypes.string,
    active: PropTypes.bool,
    onClick: PropTypes.func,
    hideOnMobile: PropTypes.bool,
    columnHeaderId: PropTypes.string
  };

  handleClick = () => {
    this.props.onClick();
  }

  render () {
    const { type, active, hideOnMobile, columnHeaderId } = this.props;

    let icon = '';

    if (this.props.icon) {
      icon = <i className={`fa fa-fw fa-${this.props.icon} column-header__icon`} />;
    }

    return (
      <div role='button heading' tabIndex='0' className={`column-header ${active ? 'active' : ''} ${hideOnMobile ? 'hidden-on-mobile' : ''}`} onClick={this.handleClick} id={columnHeaderId || null}>
        {icon}
        {type}
      </div>
    );
  }

}

export default ColumnHeader;
