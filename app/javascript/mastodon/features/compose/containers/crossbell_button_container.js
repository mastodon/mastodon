import { connect } from 'react-redux';
import TextIconButton from '../components/text_icon_button';
import { changeComposeCrossbell } from '../../../actions/compose';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  marked: { id: 'compose_form.crossbell.marked', defaultMessage: 'Also post to Crossbell' },
  unmarked: { id: 'compose_form.crossbell.unmarked', defaultMessage: 'Don\'t post to Crossbell' },
});

const mapStateToProps = (state, { intl }) => ({
  label: 'CB',
  title: intl.formatMessage(state.getIn(['compose', 'crossbell']) ? messages.marked : messages.unmarked),
  active: state.getIn(['compose', 'crossbell']),
  ariaControls: 'cw-crossbell-input',
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch(changeComposeCrossbell());
  },

});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(TextIconButton));
