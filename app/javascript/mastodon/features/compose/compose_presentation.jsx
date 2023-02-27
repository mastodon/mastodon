import React from 'react';
import ComposeFormContainer from './containers/compose_form_container';
import NavigationContainer from './containers/navigation_container';
import PropTypes from 'prop-types';
import Column from 'mastodon/components/column';
import { Helmet } from 'react-helmet';

const ComposePresentation = ({ onFocus, onBlur }) => {
  return (
    <Column onFocus={onFocus}>
      <NavigationContainer onClose={onBlur} />
      <ComposeFormContainer />

      <Helmet>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

ComposePresentation.propTypes = {
  onFocus: PropTypes.func.isRequired,
  onBlur: PropTypes.func.isRequired,
};

export default ComposePresentation;
