import PureRenderMixin from 'react-addons-pure-render-mixin';
import { FormattedMessage } from 'react-intl';
import Toggle from 'react-toggle';
import Collapsable from '../../../components/collapsable';

const UnlistedToggle = React.createClass({

  propTypes: {
    isPrivate: React.PropTypes.bool,
    isUnlisted: React.PropTypes.bool,
    isReplyToOther: React.PropTypes.bool,
    onChangeListability: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { isPrivate, isUnlisted, isReplyToOther, onChangeListability } = this.props;

    return (
      <Collapsable isVisible={!(isPrivate || isReplyToOther)} fullHeight={39.5}>
        <label className='compose-form__label'>
          <Toggle checked={isUnlisted} onChange={onChangeListability} />
          <span className='compose-form__label__text'><FormattedMessage id='compose_form.unlisted' defaultMessage='Do not display on public timelines' /></span>
        </label>
      </Collapsable>
    );
  }

});

export default UnlistedToggle;
