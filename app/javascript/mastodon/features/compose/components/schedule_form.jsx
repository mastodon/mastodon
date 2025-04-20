import PropTypes from 'prop-types';
import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import { useDispatch, useSelector} from 'react-redux';

import { changeScheduleTime } from 'mastodon/actions/compose';

const messages = defineMessages({
    schedule_time: { id: 'compose_form.schedule_time', defaultMessage: '计划发文时间（北京时间）' },
});

export const ScheduleForm = () => {
    const is_scheduled = useSelector(state => state.getIn(['compose', 'is_scheduled']));
    const schedule_time = useSelector(state => state.getIn(['compose', 'schedule_time']));
    const dispatch = useDispatch();
    const intl = useIntl();

    const handleChange = useCallback(({ target: { value } }) => {
        dispatch(changeScheduleTime(value));
    }, [dispatch]);
    
    if (!is_scheduled) {
        return null;
    }
        
    return (
        <div>
            <label>{intl.formatMessage(messages.schedule_time)}</label>
            <input 
                className='search__input'
                type='datetime-local'
                value={schedule_time}
                onChange={handleChange}
            />
        </div>
    );
}