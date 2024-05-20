import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { connect } from 'react-redux';

import { mountCompose, unmountCompose } from 'flavours/glitch/actions/compose';
import ServerBanner from 'flavours/glitch/components/server_banner';
import ComposeFormContainer from 'flavours/glitch/features/compose/containers/compose_form_container';
import SearchContainer from 'flavours/glitch/features/compose/containers/search_container';
import { identityContextPropShape, withIdentity } from 'flavours/glitch/identity_context';

import LinkFooter from './link_footer';

class ComposePanel extends PureComponent {
  static propTypes = {
    identity: identityContextPropShape,
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
    const { signedIn } = this.props.identity;

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
          <ComposeFormContainer singleColumn />
        )}

        <LinkFooter />
      </div>
    );
  }

}

export default connect()(withIdentity(ComposePanel));
