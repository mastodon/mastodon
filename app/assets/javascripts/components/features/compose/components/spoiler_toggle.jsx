import PureRenderMixin from 'react-addons-pure-render-mixin';
import { FormattedMessage } from 'react-intl';
import Toggle from 'react-toggle';

const SpoilerToggle = React.createClass({

  propTypes: {
    isSpoiler: React.PropTypes.bool,
    onChange: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { isSpoiler, onChange } = this.props;

    return (
      <label className='compose-form__label with-border' style={{ marginTop: '10px' }}>
        <Toggle checked={isSpoiler} onChange={onChange} />
        <span className='compose-form__label__text'><FormattedMessage id='compose_form.spoiler' defaultMessage='Hide text behind warning' /></span>
      </label>
    );
  }

});

export default SpoilerToggle;
