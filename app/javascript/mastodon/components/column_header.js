import React from 'react';
import NavLink from 'react-router-dom/NavLink';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';

const mapStateToProps = state => ({
  me: state.getIn(['accounts', state.getIn(['meta', 'me'])]),
  columns: state.getIn(['settings', 'columns']),
});

@connect(mapStateToProps)
export default class ColumnHeader extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    title: PropTypes.string.isRequired,
    icon: PropTypes.string.isRequired,
    active: PropTypes.bool,
    multiColumn: PropTypes.bool,
    showBackButton: PropTypes.bool,
    children: PropTypes.node,
    pinned: PropTypes.bool,
    onPin: PropTypes.func,
    onMove: PropTypes.func,
    onClick: PropTypes.func,
    me: ImmutablePropTypes.map.isRequired,
    columns: ImmutablePropTypes.list,
  };

  state = {
    collapsed: true,
    animating: false,
  };

  handleToggleClick = (e) => {
    e.stopPropagation();
    this.setState({ collapsed: !this.state.collapsed, animating: true });
  }

  handleTitleClick = () => {
    this.props.onClick();
  }

  handleMoveLeft = () => {
    this.props.onMove(-1);
  }

  handleMoveRight = () => {
    this.props.onMove(1);
  }

  handleBackClick = () => {
    if (window.history && window.history.length === 1) this.context.router.history.push('/');
    else this.context.router.history.goBack();
  }

  handleTransitionEnd = () => {
    this.setState({ animating: false });
  }

  render () {
    const { title, icon, active, children, pinned, onPin, multiColumn, showBackButton, me, columns } = this.props;
    const { collapsed, animating } = this.state;

    const wrapperClassName = classNames('column-header__wrapper', {
      'active': active,
    });

    const buttonClassName = classNames('column-header', {
      'active': active,
    });

    const collapsibleClassName = classNames('column-header__collapsible', {
      'collapsed': collapsed,
      'animating': animating,
    });

    const collapsibleButtonClassName = classNames('column-header__button', {
      'active': !collapsed,
    });

    let extraContent, pinButton, moveButtons, backButton, collapseButton, tabsBar;

    if (children) {
      extraContent = (
        <div key='extra-content' className='column-header__collapsible__extra'>
          {children}
        </div>
      );
    }

    if (multiColumn && pinned) {
      pinButton = <button key='pin-button' className='text-btn column-header__setting-btn' onClick={onPin}><i className='fa fa fa-times' /> <FormattedMessage id='column_header.unpin' defaultMessage='Unpin' /></button>;

      moveButtons = (
        <div key='move-buttons' className='column-header__setting-arrows'>
          <button className='text-btn column-header__setting-btn' onClick={this.handleMoveLeft}><i className='fa fa-chevron-left' /></button>
          <button className='text-btn column-header__setting-btn' onClick={this.handleMoveRight}><i className='fa fa-chevron-right' /></button>
        </div>
      );
    } else if (multiColumn) {
      let navItems = [];

      if (!columns.find(item => item.get('id') === 'HOME')) {
        navItems.push(<NavLink className='tabs-bar__link primary' activeClassName='active' to='/timelines/home'><i className='fa fa-fw fa-home' /></NavLink>);
      }

      if (!columns.find(item => item.get('id') === 'NOTIFICATIONS')) {
        navItems.push(<NavLink className='tabs-bar__link primary' activeClassName='active' to='/notifications'><i className='fa fa-fw fa-bell' /></NavLink>);
      }

      if (!columns.find(item => item.get('id') === 'COMMUNITY')) {
        navItems.push(<NavLink className='tabs-bar__link secondary' activeClassName='active' to='/timelines/local'><i className='fa fa-fw fa-users' /></NavLink>);
      }

      if (!columns.find(item => item.get('id') === 'PUBLIC')) {
        navItems.push(<NavLink className='tabs-bar__link secondary' activeClassName='active' to='/timelines/public'><i className='fa fa-fw fa-globe' /></NavLink>);
      }

      navItems.push(<NavLink className='tabs-bar__link primary' activeClassName='active' to='/favourites'><i className='fa fa-fw fa-star' /></NavLink>);

      if (me.get('locked')) {
        navItems.push(<NavLink className='tabs-bar__link primary' activeClassName='active' to='/follow_requests'><i className='fa fa-fw fa-users' /></NavLink>);
      }

      navItems = navItems.concat([
        <NavLink className='tabs-bar__link primary' activeClassName='active' to='/mutes'><i className='fa fa-fw fa-volume-off' /></NavLink>,
        <NavLink className='tabs-bar__link primary' activeClassName='active' to='/blocks'><i className='fa fa-fw fa-ban' /></NavLink>
      ]);
      tabsBar = (
        <div className='drawer__header'>
          {navItems}
        </div>
      );
      pinButton = <button key='pin-button' className='text-btn column-header__setting-btn' onClick={onPin}><i className='fa fa fa-plus' /> <FormattedMessage id='column_header.pin' defaultMessage='Pin' /></button>;
    }

    if (!pinned && (multiColumn || showBackButton)) {
      backButton = (
        <button onClick={this.handleBackClick} className='column-header__back-button'>
          <i className='fa fa-fw fa-chevron-left column-back-button__icon' />
          <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
        </button>
      );
    }

    const collapsedContent = [
      extraContent,
    ];

    if (multiColumn) {
      collapsedContent.push(moveButtons);
      collapsedContent.push(pinButton);
    }

    if (children || multiColumn) {
      collapseButton = <button className={collapsibleButtonClassName} onClick={this.handleToggleClick}><i className='fa fa-sliders' /></button>;
    }

    return (
      <div className={wrapperClassName}>
        {tabsBar}
        <div role='button heading' tabIndex='0' className={buttonClassName} onClick={this.handleTitleClick}>
          <i className={`fa fa-fw fa-${icon} column-header__icon`} />
          {title}

          <div className='column-header__buttons'>
            {backButton}
            {collapseButton}
          </div>
        </div>

        <div className={collapsibleClassName} onTransitionEnd={this.handleTransitionEnd}>
          <div className='column-header__collapsible-inner'>
            {(!collapsed || animating) && collapsedContent}
          </div>
        </div>
      </div>
    );
  }

}
