import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Toggle from 'react-toggle';
import Emojified from '../../../components/emojified';

export default class StatusCheckBox extends React.PureComponent {

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    checked: PropTypes.bool,
    onToggle: PropTypes.func.isRequired,
    disabled: PropTypes.bool,
  };

  render () {
    const { status, checked, onToggle, disabled } = this.props;
    const content = status.get('contentParsed');

    if (status.get('reblog')) {
      return null;
    }

    return (
      <div className='status-check-box'>
        <div className='status__content'><Emojified tokens={content} /></div>

        <div className='status-check-box-toggle'>
          <Toggle checked={checked} onChange={onToggle} disabled={disabled} />
        </div>
      </div>
    );
  }

}
