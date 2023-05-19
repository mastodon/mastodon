import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import SearchContainer from 'mastodon/features/compose/containers/search_container';
import ComposeFormContainer from 'mastodon/features/compose/containers/compose_form_container';
import NavigationContainer from 'mastodon/features/compose/containers/navigation_container';
import LinkFooter from './link_footer';
import ServerBanner from 'mastodon/components/server_banner';
import { changeComposing, mountCompose, unmountCompose } from 'mastodon/actions/compose';

class ComposePanel extends React.PureComponent {

  static contextTypes = {
    identity: PropTypes.object.isRequired,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
  };

  onFocus = () => {
    const { dispatch } = this.props;
    dispatch(changeComposing(true));
  };

  onBlur = () => {
    const { dispatch } = this.props;
    dispatch(changeComposing(false));
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(mountCompose());
  }

  componentWillUnmount () {
    const { dispatch } = this.props;
    dispatch(unmountCompose());
  }

  render() {
    const { signedIn } = this.context.identity;

    return (
      <div className='compose-panel' onFocus={this.onFocus}>
        <SearchContainer openInRoute />

        {!signedIn && (
          <React.Fragment>
            <ServerBanner />
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

export default connect()(ComposePanel);
