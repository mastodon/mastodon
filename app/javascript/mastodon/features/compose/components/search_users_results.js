import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { setupListEditor, resetListEditor } from '../../../actions/lists';
import { clearSearch } from '../../../actions/search_users';
import Account from '../../lists/components/account';
import Motion from '../../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';
import LoadMore from 'mastodon/components/load_more';

const mapStateToProps = (state) => ({
  accountIds:
    state.getIn(['listEditor', 'hashtagsUsers']) !== ''
      ? Object.values(
          JSON.parse(state.getIn(['listEditor', 'hashtagsUsers'])).users
        )
      : [],
});

const mapDispatchToProps = (dispatch) => ({
  onInitialize: (listId) => dispatch(setupListEditor(listId)),
  onClear: () => dispatch(clearSearch()),
  onReset: () => dispatch(resetListEditor()),
});


export default
@connect(mapStateToProps, mapDispatchToProps)
@injectIntl
class SearchUsersResults extends ImmutablePureComponent {
  static propTypes = {
    results: ImmutablePropTypes.map.isRequired,
    accountIds: PropTypes.instanceOf(Array).isRequired,
    expandSearch: PropTypes.func.isRequired,
    searchTerm: PropTypes.string,
    intl: PropTypes.object.isRequired,
    onClear: PropTypes.func.isRequired,
  };

  handleLoadMoreAccounts = () => this.props.expandSearch('accounts');

  render() {
    const {
      results,
      onClear,
      accountIds,
    } = this.props;


    let accounts;
    let count = 0;

    if (results.get('accounts') && results.get('accounts').size > 0)
      count += results.get('accounts').size;
    accounts = (
      <div className="drawer__pager">
        <div className="drawer__inner list-editor__accounts">
          {accountIds.map((accountId) => (
            <Account key={accountId} accountId={accountId} added />
          ))}
        </div>

        {count > 0 && (
          <div
            role="button"
            tabIndex="-1"
            className="drawer__backdrop"
            onClick={onClear}
          />
        )}

        {results.get('accounts') && results.get('accounts').size > 0 && (
          <Motion
            defaultStyle={{ x: -100 }}
            style={{
              x: spring(count > 0 ? 0 : -100, {
                stiffness: 210,
                damping: 20,
              }),
            }}
          >
            {({ x }) => (
              <div
                className="drawer__inner backdrop"
                style={{
                  transform: x === 0 ? null : `translateX(${x}%)`,
                  visibility: x === -100 ? 'hidden' : 'visible',
                }}
              >
                {results.get('accounts').map((accountId) => (
                  <Account key={accountId} accountId={accountId} />
                ))}

                {results.get('accounts').size >= 3 && (
                  <LoadMore visible onClick={this.handleLoadMoreAccounts} />
                )}
              </div>
            )}
          </Motion>
        )}
      </div>
    );

    return <div className="search-results">{accounts}</div>;
  }
}
