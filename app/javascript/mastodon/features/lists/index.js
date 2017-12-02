import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import Column from '../ui/components/column';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import { fetchLists } from '../../actions/lists';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ColumnLink from '../ui/components/column_link';
import ColumnSubheading from '../ui/components/column_subheading';
import NewListForm from './components/new_list_form';

const messages = defineMessages({
  heading: { id: 'column.lists', defaultMessage: 'Lists' },
  subheading: { id: 'lists.subheading', defaultMessage: 'Your lists' },
});

const mapStateToProps = state => ({
  lists: state.get('lists'),
});

@connect(mapStateToProps)
@injectIntl
export default class Lists extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    lists: ImmutablePropTypes.map,
    intl: PropTypes.object.isRequired,
  };

  componentWillMount () {
    this.props.dispatch(fetchLists());
  }

  render () {
    const { intl, lists } = this.props;

    if (!lists) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    return (
      <Column icon='bars' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />

        <NewListForm />

        <div className='scrollable'>
          <ColumnSubheading text={intl.formatMessage(messages.subheading)} />

          {lists.toList().map(list =>
            <ColumnLink key={list.get('id')} to={`/timeline/list/${list.get('id')}`} icon='bars' text={list.get('title')} />
          )}
        </div>
      </Column>
    );
  }

}
