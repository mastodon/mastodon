import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import emojify from '../../../emoji';
import Toggle from 'react-toggle';

class StatusCheckBox extends React.PureComponent {

  render () {
    const { status, checked, onToggle, disabled } = this.props;
    const content = { __html: emojify(status.get('content')) };

    if (status.get('reblog')) {
      return null;
    }

    return (
      <div className='status-check-box'>
        <div
          className='status__content'
          dangerouslySetInnerHTML={content}
        />

        <div className='status-check-box-toggle'>
          <Toggle checked={checked} onChange={onToggle} disabled={disabled} />
        </div>
      </div>
    );
  }

}

StatusCheckBox.propTypes = {
  status: ImmutablePropTypes.map.isRequired,
  checked: PropTypes.bool,
  onToggle: PropTypes.func.isRequired,
  disabled: PropTypes.bool
};

export default StatusCheckBox;
