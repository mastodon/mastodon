import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import { ScrollContainer } from 'react-router-scroll';
import Column from '../ui/components/column';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import AccountContainer from '../../containers/account_container';
import { fetchBlocks, expandBlocks } from '../../actions/blocks';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  heading: { id: 'column.blocks', defaultMessage: 'Blocked users' }
});

const mapStateToProps = state => ({
  accountIds: state.getIn(['user_lists', 'blocks', 'items'])
});

const Blocks = React.createClass({
  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list,
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this.props.dispatch(fetchBlocks());
  },

  handleScroll (e) {
    const { scrollTop, scrollHeight, clientHeight } = e.target;

    if (scrollTop === scrollHeight - clientHeight) {
      this.props.dispatch(expandBlocks());
    }
  },

  render () {
    const { intl, accountIds } = this.props;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    return (
      <Column icon='ban' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />
        <ScrollContainer scrollKey='blocks'>
          <div className='scrollable' onScroll={this.handleScroll}>
            {accountIds.map(id =>
              <AccountContainer key={id} id={id} />
            )}
          </div>
        </ScrollContainer>
      </Column>
    );
  }
});

export default connect(mapStateToProps)(injectIntl(Blocks));
