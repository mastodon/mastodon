import { injectIntl,defineMessages } from "react-intl";

import { connect } from "react-redux";

import ScheduleIcon from '@/material-icons/400-20px/schedule.svg?react';
import { IconButton } from "@/mastodon/components/icon_button";





const mapStateToProps = () => ({
    iconComponent: ScheduleIcon,
    title: defineMessages({
        title: {
            id: 'compose.schedule_button.title',
            defaultMessage: 'Schedule',
        },
    }),
    active: false,
    ariaControls: 'schedule-compose-form',
    size: 18,
    inverted: true,
});

const mapDispatchToProps = dispatch => ({
    onClick () {
        dispatch({ type: 'SCHEDULE_COMPOSE' });
    },
});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(IconButton));