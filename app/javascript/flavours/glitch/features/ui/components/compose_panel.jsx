import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import SearchContainer from 'flavours/glitch/features/compose/containers/search_container';
import ComposeFormContainer from 'flavours/glitch/features/compose/containers/compose_form_container';
import NavigationContainer from 'flavours/glitch/features/compose/containers/navigation_container';
import LinkFooter from './link_footer';
import ServerBanner from 'flavours/glitch/components/server_banner';
import { mountCompose, unmountCompose } from 'flavours/glitch/actions/compose';

export default @connect()
class ComposePanel extends React.PureComponent {

  static contextTypes = {
    identity: PropTypes.object.isRequired,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
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
      <div className='compose-panel'>
        <SearchContainer openInRoute />

        {!signedIn && (
          <React.Fragment>
            <ServerBanner />
            <div className='flex-spacer' />
          </React.Fragment>
        )}

        {signedIn && (
          <React.Fragment>
            <NavigationContainer />
            <ComposeFormContainer singleColumn />
          </React.Fragment>
        )}

        <LinkFooter />
      </div>
    );
  }

}
