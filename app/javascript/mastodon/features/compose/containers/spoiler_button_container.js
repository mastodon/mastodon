import { connect } from 'react-redux';
import TextIconButton from '../components/text_icon_button';
import { changeComposeSpoilerness } from '../../../actions/compose';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  marked: { id: 'compose_form.spoiler.marked', defaultMessage: 'Text is hidden behind warning' },
  unmarked: { id: 'compose_form.spoiler.unmarked', defaultMessage: 'Text is not hidden' },
});

const mapStateToProps = (state, { intl }) => ({
  label: 'CW',
  title: intl.formatMessage(state.getIn(['compose', 'spoiler']) ? messages.marked : messages.unmarked),
  active: state.getIn(['compose', 'spoiler']),
  ariaControls: 'cw-spoiler-input',
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch(changeComposeSpoilerness());
  },

});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(TextIconButton));
