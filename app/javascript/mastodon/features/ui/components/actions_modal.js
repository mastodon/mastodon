import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class ReportModal extends ImmutablePureComponent {

  static propTypes = {
    actions: PropTypes.array,
    onClick: PropTypes.func,
    intl: PropTypes.object.isRequired,
  };

  renderAction = (action, i) => {
    if (action === null) {
      return <li key={`sep-${i}`} className='dropdown__sep' />;
    }

    const { text, href = '#' } = action;

    return (
      <li key={`${text}-${i}`}>
        <a href={href} target='_blank' rel='noopener' onClick={this.props.onClick} data-index={i}>
          {text}
        </a>
      </li>
    );
  }

  render () {
    return (
      <div className='modal-root__modal actions-modal'>
        <ul>
          {this.props.actions.map(this.renderAction)}
        </ul>
      </div>
    );
  }

}
