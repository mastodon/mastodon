import PropTypes from 'prop-types';
import React from 'react';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { createSelector } from 'reselect';

import MotionPhotosOnIcon from '@/material-icons/400-24px/motion_photos_on.svg?react';
import ColumnHeader from 'mastodon/components/column_header';

import { fetchCircles } from '../../actions/circles';
import { LoadingIndicator } from '../../components/loading_indicator';
import ScrollableList from '../../components/scrollable_list';
import Column from '../ui/components/column';
import ColumnSubheading from '../ui/components/column_subheading';

import Circle from './components/circle';
import NewCircleForm from './components/new_circle_form';



const messages = defineMessages({
  heading: { id: 'column.circles', defaultMessage: 'Circles' },
  subheading: { id: 'circles.subheading', defaultMessage: 'Your circles' },
});

const getOrderedCircles = createSelector([state => state.get('circles')], circles => {
  if (!circles) {
    return circles;
  }

  return circles.toList().filter(item => !!item).sort((a, b) => a.get('title').localeCompare(b.get('title')));
});

const mapStateToProps = state => ({
  circles: getOrderedCircles(state),
});

class Circles extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    circles: ImmutablePropTypes.list,
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  componentWillMount () {
    this.props.dispatch(fetchCircles());
  }

  render () {
    const { intl, circles, multiColumn } = this.props;

    if (!circles) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='empty_column.circles' defaultMessage="You don't have any circles yet. When you create one, it will show up here." />;

    return (
      <Column bindToDocument={!multiColumn} label={intl.formatMessage(messages.heading)}>
        <ColumnHeader title={intl.formatMessage(messages.heading)} icon='motion_photos_on' iconComponent={MotionPhotosOnIcon} multiColumn={multiColumn} />

        <NewCircleForm />

        <ScrollableList
          scrollKey='circles'
          emptyMessage={emptyMessage}
          prepend={<ColumnSubheading text={intl.formatMessage(messages.subheading)} />}
          bindToDocument={!multiColumn}
        >
          {circles.map(circle =>
            <Circle key={`${circle.get('id')}-${circle.get('title')}`} id={circle.get('id')} text={circle.get('title')} />,
          )}
        </ScrollableList>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Circles));
