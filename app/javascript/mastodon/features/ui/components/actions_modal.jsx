import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import IconButton from '../../../components/icon_button';
import classNames from 'classnames';

export default class ActionsModal extends ImmutablePureComponent {

  static propTypes = {
    status: ImmutablePropTypes.map,
    actions: PropTypes.array,
    onClick: PropTypes.func,
  };

  renderAction = (action, i) => {
    if (action === null) {
      return <li key={`sep-${i}`} className='dropdown-menu__separator' />;
    }

    const { icon = null, text, meta = null, active = false, href = '#' } = action;

    return (
      <li key={`${text}-${i}`}>
        <a href={href} target='_blank' rel='noopener noreferrer' onClick={this.props.onClick} data-index={i} className={classNames({ active })}>
          {icon && <IconButton title={text} icon={icon} role='presentation' tabIndex={-1} inverted />}
          <div>
            <div className={classNames({ 'actions-modal__item-label': !!meta })}>{text}</div>
            <div>{meta}</div>
          </div>
        </a>
      </li>
    );
  };

  render () {
    return (
      <div className='modal-root__modal actions-modal'>
        <ul className={classNames({ 'with-status': !!status })}>
          {this.props.actions.map(this.renderAction)}
        </ul>
      </div>
    );
  }

}
