import React from 'react';
import PropTypes from 'prop-types';
import SearchContainer from 'flavours/glitch/features/compose/containers/search_container';
import ComposeFormContainer from 'flavours/glitch/features/compose/containers/compose_form_container';
import NavigationContainer from 'flavours/glitch/features/compose/containers/navigation_container';
import LinkFooter from './link_footer';
import ServerBanner from 'flavours/glitch/components/server_banner';

export default
class ComposePanel extends React.PureComponent {

  static contextTypes = {
    identity: PropTypes.object.isRequired,
  };

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

        <LinkFooter withHotkeys />
      </div>
    );
  }

};
