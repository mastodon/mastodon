import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { debounce } from 'lodash';

import ScrollableList from 'flavours/glitch/components/scrollable_list';

import { fetchDomainBlocks, expandDomainBlocks } from '../../actions/domain_blocks';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import LoadingIndicator from '../../components/loading_indicator';
import DomainContainer from '../../containers/domain_container';
import Column from '../ui/components/column';





const messages = defineMessages({
  heading: { id: 'column.domain_blocks', defaultMessage: 'Blocked domains' },
  unblockDomain: { id: 'account.unblock_domain', defaultMessage: 'Unblock domain {domain}' },
});

const mapStateToProps = state => ({
  domains: state.getIn(['domain_lists', 'blocks', 'items']),
  hasMore: !!state.getIn(['domain_lists', 'blocks', 'next']),
});

class Blocks extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    hasMore: PropTypes.bool,
    domains: ImmutablePropTypes.list,
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  UNSAFE_componentWillMount () {
    this.props.dispatch(fetchDomainBlocks());
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandDomainBlocks());
  }, 300, { leading: true });

  render () {
    const { intl, domains, hasMore, multiColumn } = this.props;

    if (!domains) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='empty_column.domain_blocks' defaultMessage='There are no blocked domains yet.' />;

    return (
      <Column bindToDocument={!multiColumn} icon='minus-circle' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />

        <ScrollableList
          scrollKey='domain_blocks'
          onLoadMore={this.handleLoadMore}
          hasMore={hasMore}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
        >
          {domains.map(domain =>
            <DomainContainer key={domain} domain={domain} />,
          )}
        </ScrollableList>

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Blocks));
