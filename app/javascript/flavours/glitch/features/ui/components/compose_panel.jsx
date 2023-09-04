import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { connect } from 'react-redux';

import { mountCompose, unmountCompose } from 'flavours/glitch/actions/compose';
import ServerBanner from 'flavours/glitch/components/server_banner';
import ComposeFormContainer from 'flavours/glitch/features/compose/containers/compose_form_container';
import NavigationContainer from 'flavours/glitch/features/compose/containers/navigation_container';
import SearchContainer from 'flavours/glitch/features/compose/containers/search_container';

import LinkFooter from './link_footer';


class ComposePanel extends PureComponent {

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
          <>
            <ServerBanner />
            <div className='flex-spacer' />
          </>
        )}

        {signedIn && (
          <>
            <NavigationContainer />
            <ComposeFormContainer singleColumn />
          </>
        )}

        <LinkFooter />
      </div>
    );
  }

}

export default connect()(ComposePanel);
