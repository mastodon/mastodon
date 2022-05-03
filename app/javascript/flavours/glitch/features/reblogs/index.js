import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from 'flavours/glitch/components/loading_indicator';
import { fetchReblogs } from 'flavours/glitch/actions/interactions';
import AccountContainer from 'flavours/glitch/containers/account_container';
import Column from 'flavours/glitch/features/ui/components/column';
import Icon from 'flavours/glitch/components/icon';
import ColumnHeader from 'flavours/glitch/components/column_header';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ScrollableList from 'flavours/glitch/components/scrollable_list';

const messages = defineMessages({
  heading: { id: 'column.reblogged_by', defaultMessage: 'Boosted by' },
  refresh: { id: 'refresh', defaultMessage: 'Refresh' },
});

const mapStateToProps = (state, props) => ({
  accountIds: state.getIn(['user_lists', 'reblogged_by', props.params.statusId]),
});

export default @connect(mapStateToProps)
@injectIntl
class Reblogs extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list,
    multiColumn: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  componentWillMount () {
    if (!this.props.accountIds) {
      this.props.dispatch(fetchReblogs(this.props.params.statusId));
    }
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.statusId !== this.props.params.statusId && nextProps.params.statusId) {
      this.props.dispatch(fetchReblogs(nextProps.params.statusId));
    }
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  setRef = c => {
    this.column = c;
  }

  handleRefresh = () => {
    this.props.dispatch(fetchReblogs(this.props.params.statusId));
  }

  render () {
    const { intl, accountIds, multiColumn } = this.props;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='status.reblogs.empty' defaultMessage='No one has boosted this post yet. When someone does, they will show up here.' />;

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='retweet'
          title={intl.formatMessage(messages.heading)}
          onClick={this.handleHeaderClick}
          showBackButton
          multiColumn={multiColumn}
          extraButton={(
            <button className='column-header__button' title={intl.formatMessage(messages.refresh)} aria-label={intl.formatMessage(messages.refresh)} onClick={this.handleRefresh}><Icon id='refresh' /></button>
          )}
        />

        <ScrollableList
          scrollKey='reblogs'
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
        >
          {accountIds.map(id =>
            <AccountContainer key={id} id={id} withNote={false} />,
          )}
        </ScrollableList>
      </Column>
    );
  }

}
