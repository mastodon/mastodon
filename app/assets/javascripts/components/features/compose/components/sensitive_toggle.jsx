import PureRenderMixin from 'react-addons-pure-render-mixin';
import { FormattedMessage } from 'react-intl';
import Toggle from 'react-toggle';
import Collapsable from '../../../components/collapsable';

const SensitiveToggle = React.createClass({

  propTypes: {
    hasMedia: React.PropTypes.bool,
    isSensitive: React.PropTypes.bool,
    onChange: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { hasMedia, isSensitive, onChange } = this.props;

    return (
      <Collapsable isVisible={hasMedia} fullHeight={39.5}>
        <label className='compose-form__label'>
          <Toggle checked={isSensitive} onChange={onChange} />
          <span className='compose-form__label__text'><FormattedMessage id='compose_form.sensitive' defaultMessage='Mark media as sensitive' /></span>
        </label>
      </Collapsable>
    );
  }

});

export default SensitiveToggle;
