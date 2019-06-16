import React from 'react';
import SearchContainer from 'flavours/glitch/features/compose/containers/search_container';
import ComposeFormContainer from 'flavours/glitch/features/compose/containers/compose_form_container';
import NavigationContainer from 'flavours/glitch/features/compose/containers/navigation_container';
import LinkFooter from './link_footer';

const ComposePanel = () => (
  <div className='compose-panel'>
    <SearchContainer openInRoute />
    <NavigationContainer />
    <ComposeFormContainer singleColumn />
    <LinkFooter withHotkeys />
  </div>
);

export default ComposePanel;
