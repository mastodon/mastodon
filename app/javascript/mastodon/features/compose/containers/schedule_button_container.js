import { injectIntl, defineMessages } from "react-intl";

import { connect } from "react-redux";

import ScheduleIcon from '@/material-icons/400-20px/schedule.svg?react';
import { IconButton } from "@/mastodon/components/icon_button";

import { changeIsScheduled } from '../../actions/compose';



const mapStateToProps = (state) => ({
    iconComponent: ScheduleIcon,
    title: 'schedule',
    active: state.getIn(['compose', 'is_scheduled']),
    
    size: 18,
    inverted: true,
});

const mapDispatchToProps = dispatch => ({
    onClick () {
        dispatch(changeIsScheduled());
    },
});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(IconButton));