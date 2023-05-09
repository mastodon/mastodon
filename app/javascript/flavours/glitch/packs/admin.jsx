import 'packs/public-path';
import ready from 'flavours/glitch/ready';
import React from 'react';
import ReactDOM from 'react-dom';

ready(() => {
  [].forEach.call(document.querySelectorAll('[data-admin-component]'), element => {
    const componentName  = element.getAttribute('data-admin-component');
    const { locale, ...componentProps } = JSON.parse(element.getAttribute('data-props'));

    import('flavours/glitch/containers/admin_component').then(({ default: AdminComponent }) => {
      return import('flavours/glitch/components/admin/' + componentName).then(({ default: Component }) => {
        ReactDOM.render((
          <AdminComponent locale={locale}>
            <Component {...componentProps} />
          </AdminComponent>
        ), element);
      });
    }).catch(error => {
      console.error(error);
    });
  });
});
