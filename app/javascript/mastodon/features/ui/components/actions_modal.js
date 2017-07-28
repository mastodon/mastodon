import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import StatusContent from '../../../components/status_content';
import Avatar from '../../../components/avatar';
import RelativeTimestamp from '../../../components/relative_timestamp';
import DisplayName from '../../../components/display_name';
import IconButton from '../../../components/icon_button';

export default class ActionsModal extends ImmutablePureComponent {

  static propTypes = {
    actions: PropTypes.array,
    onClick: PropTypes.func,
  };

  renderAction = (action, i) => {
    if (action === null) {
      return <li key={`sep-${i}`} className='dropdown__sep' />;
    }

    const { icon = null, text, meta = null, active = false, href = '#' } = action;

    return (
      <li key={`${text}-${i}`}>
        <a href={href} target='_blank' rel='noopener' onClick={this.props.onClick} data-index={i} className={active && 'active'}>
          {icon && <IconButton title={text} icon={icon} role='presentation' tabIndex='-1' />}
          <div>
            <div>{text}</div>
            <div>{meta}</div>
          </div>
        </a>
      </li>
    );
  }

  render () {
    const status = this.props.status && (
      <div className='status light'>
        <div className='boost-modal__status-header'>
          <div className='boost-modal__status-time'>
            <a href={this.props.status.get('url')} className='status__relative-time' target='_blank' rel='noopener'>
              <RelativeTimestamp timestamp={this.props.status.get('created_at')} />
            </a>
          </div>

          <a href={this.props.status.getIn(['account', 'url'])} className='status__display-name'>
            <div className='status__avatar'>
              <Avatar src={this.props.status.getIn(['account', 'avatar'])} staticSrc={this.props.status.getIn(['account', 'avatar_static'])} size={48} />
            </div>

            <DisplayName account={this.props.status.get('account')} />
          </a>
        </div>

        <StatusContent status={this.props.status} />
      </div>
    );

    return (
      <div className='modal-root__modal actions-modal'>
        {status}

        <ul>
          {this.props.actions.map(this.renderAction)}
        </ul>
      </div>
    );
  }

}
