import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import { Helmet } from 'react-helmet';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { getStatusList } from 'mastodon/selectors';

import { fetchPinnedStatuses } from '../../actions/pin_statuses';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import StatusList from '../../components/status_list';
import Column from '../ui/components/column';

const messages = defineMessages({
  heading: { id: 'column.pins', defaultMessage: 'Pinned post' },
});

const mapStateToProps = state => ({
  statusIds: getStatusList(state, 'pins'),
  hasMore: !!state.getIn(['status_lists', 'pins', 'next']),
});

class PinnedStatuses extends ImmutablePureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list.isRequired,
    intl: PropTypes.object.isRequired,
    hasMore: PropTypes.bool.isRequired,
    multiColumn: PropTypes.bool,
  };

  UNSAFE_componentWillMount () {
    this.props.dispatch(fetchPinnedStatuses());
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

  setRef = c => {
    this.column = c;
  };

  render () {
    const { intl, statusIds, hasMore, multiColumn } = this.props;

    return (
      <Column bindToDocument={!multiColumn} icon='thumb-tack' heading={intl.formatMessage(messages.heading)} ref={this.setRef}>
        <ColumnBackButtonSlim />
        <StatusList
          statusIds={statusIds}
          scrollKey='pinned_statuses'
          hasMore={hasMore}
          bindToDocument={!multiColumn}
        />
        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(PinnedStatuses));
