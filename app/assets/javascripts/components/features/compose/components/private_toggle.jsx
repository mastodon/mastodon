import PureRenderMixin from 'react-addons-pure-render-mixin';
import { FormattedMessage } from 'react-intl';
import Toggle from 'react-toggle';

const PrivateToggle = React.createClass({

  propTypes: {
    isPrivate: React.PropTypes.bool,
    onChange: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { isPrivate, onChange } = this.props;

    return (
      <label className='compose-form__label with-border'>
        <Toggle checked={isPrivate} onChange={onChange} />
        <span className='compose-form__label__text'><FormattedMessage id='compose_form.private' defaultMessage='Mark as private' /></span>
      </label>
    );
  }

});

export default PrivateToggle;
