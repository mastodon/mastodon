import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';
import { injectIntl, defineMessages } from 'react-intl';
import Column from '../ui/components/column';
import ColumnHeader from '../../components/column_header';
import Hashtag from '../../components/hashtag';
import classNames from 'classnames';
import { fetchTrends } from '../../actions/trends';

const messages = defineMessages({
  title: { id: 'trends.header', defaultMessage: 'Trending now' },
  refreshTrends: { id: 'trends.refresh', defaultMessage: 'Refresh trends' },
});

const mapStateToProps = state => ({
  trends: state.getIn(['trends', 'items']),
  loading: state.getIn(['trends', 'isLoading']),
});

const mapDispatchToProps = dispatch => ({
  fetchTrends: () => dispatch(fetchTrends()),
});

@connect(mapStateToProps, mapDispatchToProps)
@injectIntl
export default class Trends extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    trends: ImmutablePropTypes.list,
    fetchTrends: PropTypes.func.isRequired,
    loading: PropTypes.bool,
  };

  componentDidMount () {
    this.props.fetchTrends();
  }

  handleRefresh = () => {
    this.props.fetchTrends();
  }

  render () {
    const { trends, loading, intl } = this.props;

    return (
      <Column>
        <ColumnHeader
          icon='fire'
          title={intl.formatMessage(messages.title)}
          extraButton={(
            <button className='column-header__button' title={intl.formatMessage(messages.refreshTrends)} aria-label={intl.formatMessage(messages.refreshTrends)} onClick={this.handleRefresh}><i className={classNames('fa', 'fa-refresh', { 'fa-spin': loading })} /></button>
          )}
        />

        <div className='scrollable'>
          {trends && trends.map(hashtag => <Hashtag key={hashtag.get('name')} hashtag={hashtag} />)}
        </div>
      </Column>
    );
  }

}
