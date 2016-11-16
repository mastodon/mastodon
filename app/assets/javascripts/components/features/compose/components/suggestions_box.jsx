import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import AccountContainer from '../../followers/containers/account_container';
import { FormattedMessage } from 'react-intl';

const outerStyle = {
  position: 'relative'
};

const headerStyle = {
  fontSize: '14px',
  fontWeight: '500',
  display: 'block',
  padding: '10px',
  color: '#9baec8',
  background: '#454b5e',
  overflow: 'hidden'
};

const nextStyle = {
  display: 'inline-block',
  float: 'right',
  fontWeight: '400',
  color: '#2b90d9'
};

const SuggestionsBox = React.createClass({

  propTypes: {
    accountIds: ImmutablePropTypes.list,
    perWindow: React.PropTypes.number
  },

  getInitialState () {
    return {
      index: 0
    };
  },

  getDefaultProps () {
    return {
      perWindow: 2
    };
  },

  mixins: [PureRenderMixin],

  handleNextClick (e) {
    e.preventDefault();

    let newIndex = this.state.index + 1;

    if (this.props.accountIds.skip(this.props.perWindow * newIndex).size === 0) {
      newIndex = 0;
    }

    this.setState({ index: newIndex });
  },

  render () {
    const { accountIds, perWindow } = this.props;

    if (!accountIds || accountIds.size === 0) {
      return <div />;
    }

    let nextLink = '';

    if (accountIds.size > perWindow) {
      nextLink = <a href='#' style={nextStyle} onClick={this.handleNextClick}><FormattedMessage id='suggestions_box.refresh' defaultMessage='Refresh' /></a>;
    }

    return (
      <div style={outerStyle}>
        <strong style={headerStyle}>
          <FormattedMessage id='suggestions_box.who_to_follow' defaultMessage='Who to follow' /> {nextLink}
        </strong>

        {accountIds.skip(perWindow * this.state.index).take(perWindow).map(accountId => <AccountContainer key={accountId} id={accountId} withNote={false} />)}
      </div>
    );
  }

});

export default SuggestionsBox;
