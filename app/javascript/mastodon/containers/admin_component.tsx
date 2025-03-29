import React, { ReactNode } from 'react';

import { IntlProvider } from 'mastodon/locales';

interface Props {
  children: ReactNode;
}

const AdminComponent: React.FC<Props> = ({ children }) => {
  return (
    <IntlProvider>
      {children}
    </IntlProvider>
  );
};

export default AdminComponent;
