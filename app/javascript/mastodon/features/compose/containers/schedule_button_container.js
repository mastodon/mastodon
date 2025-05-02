import { injectIntl, defineMessages } from "react-intl";

import { connect } from 'react-redux';

import ScheduleIcon from '@/material-icons/400-20px/schedule.svg?react';
import { IconButton } from "@/mastodon/components/icon_button";

import { changeIsScheduled } from '../../../actions/compose';

const messages = defineMessages({
    marked: { id: 'compose_form.schedule.marked', defaultMessage: 'This post will be published at the time chosen below'},
    unmarked: { id: 'compose_form.schedule.unmarked', defaultMessage: 'This post will be published at once'},
})

const mapStateToProps = (state, { intl }) => ({
    iconComponent: ScheduleIcon,
    title: intl.formatMessage(state.getIn(['compose', 'is_scheduled']) ? messages.marked : messages.unmarked),
    active: state.getIn(['compose', 'is_scheduled']),
    ariaControls: 'schedule-publish',
    size: 18,
    inverted: true,
});

const mapDispatchToProps = dispatch => ({
    onClick () {
        dispatch(changeIsScheduled());
    },
});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(IconButton));