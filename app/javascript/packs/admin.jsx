import './public-path';
import ready from '../mastodon/ready';
import React from 'react';
import { createRoot } from 'react-dom/client';

ready(() => {
  [].forEach.call(document.querySelectorAll('[data-admin-component]'), element => {
    const componentName  = element.getAttribute('data-admin-component');
    const { locale, ...componentProps } = JSON.parse(element.getAttribute('data-props'));

    import('../mastodon/containers/admin_component').then(({ default: AdminComponent }) => {
      return import('../mastodon/components/admin/' + componentName).then(({ default: Component }) => {
        const root = createRoot(element);

        root.render (
          <AdminComponent locale={locale}>
            <Component {...componentProps} />
          </AdminComponent>,
        );
      });
    }).catch(error => {
      console.error(error);
    });
  });
});
