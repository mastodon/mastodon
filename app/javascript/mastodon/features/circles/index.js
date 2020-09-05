import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import Column from '../ui/components/column';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import { fetchCircles } from '../../actions/circles';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ColumnSubheading from '../ui/components/column_subheading';
import NewCircleForm from './components/new_circle_form';
import Circle from './components/circle';
import { createSelector } from 'reselect';
import ScrollableList from '../../components/scrollable_list';

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

export default @connect(mapStateToProps)
@injectIntl
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
    const { intl, shouldUpdateScroll, circles, multiColumn } = this.props;

    if (!circles) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='empty_column.circles' defaultMessage="You don't have any circles yet. When you create one, it will show up here." />;

    return (
      <Column bindToDocument={!multiColumn} icon='user-circle' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />

        <NewCircleForm />

        <ScrollableList
          scrollKey='circles'
          shouldUpdateScroll={shouldUpdateScroll}
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
