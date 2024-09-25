import { injectIntl, defineMessages } from 'react-intl';

import { connect } from 'react-redux';

import WarningIcon from '@/material-icons/400-20px/warning.svg?react';
import { IconButton } from 'mastodon/components/icon_button';

import { changeComposeSpoilerness } from '../../../actions/compose';

const messages = defineMessages({
  marked: { id: 'compose_form.spoiler.marked', defaultMessage: 'Text is hidden behind warning' },
  unmarked: { id: 'compose_form.spoiler.unmarked', defaultMessage: 'Text is not hidden' },
});

const mapStateToProps = (state, { intl }) => ({
  iconComponent: WarningIcon,
  title: intl.formatMessage(state.getIn(['compose', 'spoiler']) ? messages.marked : messages.unmarked),
  active: state.getIn(['compose', 'spoiler']),
  ariaControls: 'cw-spoiler-input',
  size: 18,
  inverted: true,
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch(changeComposeSpoilerness());
  },

});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(IconButton));
