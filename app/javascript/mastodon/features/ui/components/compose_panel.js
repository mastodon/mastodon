import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import SearchContainer from 'mastodon/features/compose/containers/search_container';
import ComposeFormContainer from 'mastodon/features/compose/containers/compose_form_container';
import NavigationContainer from 'mastodon/features/compose/containers/navigation_container';
import LinkFooter from './link_footer';
import { changeComposing } from 'mastodon/actions/compose';

export default @connect()
class ComposePanel extends React.PureComponent {

  static contextTypes = {
    identity: PropTypes.object.isRequired,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
  };

  onFocus = () => {
    this.props.dispatch(changeComposing(true));
  }

  onBlur = () => {
    this.props.dispatch(changeComposing(false));
  }

  render() {
    const { signedIn } = this.context.identity;

    return (
      <div className='compose-panel' onFocus={this.onFocus}>
        <SearchContainer openInRoute />

        {!signedIn && (
          <React.Fragment>
            <div className='flex-spacer' />
          </React.Fragment>
        )}

        {signedIn && (
          <React.Fragment>
            <NavigationContainer onClose={this.onBlur} />
            <ComposeFormContainer singleColumn />
          </React.Fragment>
        )}

        <LinkFooter />
      </div>
    );
  }

}
