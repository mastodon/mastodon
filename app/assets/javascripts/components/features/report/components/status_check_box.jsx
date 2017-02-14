import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import emojify from '../../../emoji';
import Toggle from 'react-toggle';

const StatusCheckBox = React.createClass({

  propTypes: {
    status: ImmutablePropTypes.map.isRequired,
    checked: React.PropTypes.bool,
    onToggle: React.PropTypes.func.isRequired,
    disabled: React.PropTypes.bool
  },

  mixins: [PureRenderMixin],

  render () {
    const { status, checked, onToggle, disabled } = this.props;
    const content = { __html: emojify(status.get('content')) };

    return (
      <div className='status-check-box' style={{ display: 'flex' }}>
        <div
          className='status__content'
          style={{ flex: '1 1 auto', padding: '10px' }}
          dangerouslySetInnerHTML={content}
        />

        <div style={{ flex: '0 0 auto', padding: '10px', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
          <Toggle checked={checked} onChange={onToggle} disabled={disabled} />
        </div>
      </div>
    );
  }

});

export default StatusCheckBox;
