import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import ColumnHeader from 'flavours/glitch/components/column_header';
import Icon from 'flavours/glitch/components/icon';
import { fetchFavourites } from 'flavours/glitch/actions/interactions';
import LoadingIndicator from 'flavours/glitch/components/loading_indicator';
import ScrollableList from 'flavours/glitch/components/scrollable_list';
import AccountContainer from 'flavours/glitch/containers/account_container';
import Column from 'flavours/glitch/features/ui/components/column';
import { Helmet } from 'react-helmet';

const messages = defineMessages({
  heading: { id: 'column.favourited_by', defaultMessage: 'Favourited by' },
  refresh: { id: 'refresh', defaultMessage: 'Refresh' },
});

const mapStateToProps = (state, props) => ({
  accountIds: state.getIn(['user_lists', 'favourited_by', props.params.statusId]),
});

export default @connect(mapStateToProps)
@injectIntl
class Favourites extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list,
    multiColumn: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  componentWillMount () {
    if (!this.props.accountIds) {
      this.props.dispatch(fetchFavourites(this.props.params.statusId));
    }
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.statusId !== this.props.params.statusId && nextProps.params.statusId) {
      this.props.dispatch(fetchFavourites(nextProps.params.statusId));
    }
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

  setRef = c => {
    this.column = c;
  };

  handleRefresh = () => {
    this.props.dispatch(fetchFavourites(this.props.params.statusId));
  };

  render () {
    const { intl, accountIds, multiColumn } = this.props;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='empty_column.favourites' defaultMessage='No one has favourited this post yet. When someone does, they will show up here.' />;

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='star'
          title={intl.formatMessage(messages.heading)}
          onClick={this.handleHeaderClick}
          showBackButton
          multiColumn={multiColumn}
          extraButton={(
            <button className='column-header__button' title={intl.formatMessage(messages.refresh)} aria-label={intl.formatMessage(messages.refresh)} onClick={this.handleRefresh}><Icon id='refresh' /></button>
          )}
        />
        <ScrollableList
          scrollKey='favourites'
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
        >
          {accountIds.map(id =>
            <AccountContainer key={id} id={id} withNote={false} />,
          )}
        </ScrollableList>

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}
