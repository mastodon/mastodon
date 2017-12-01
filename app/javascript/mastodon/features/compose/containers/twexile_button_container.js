import { connect } from 'react-redux';
import TextIconButton from '../components/text_icon_button';
import { changeTwexileStatus } from '../../../actions/twexile';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  title: { id: 'compose_form.twexile', defaultMessage: 'Sync to Twitter' },
});

const mapStateToProps = (state, { intl }) => ({
  label: 'TW',
  title: intl.formatMessage(messages.title),
  active: state.getIn(['compose', 'twexile']),
  ariaControls: 'tw-twexile-input',
});

const mapDispatchToProps = dispatch => ({
  onClick () {
    dispatch(changeTwexileStatus());
  },

});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(TextIconButton));
