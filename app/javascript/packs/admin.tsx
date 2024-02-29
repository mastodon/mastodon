import './public-path';
import { createRoot } from 'react-dom/client';

import ready from '../mastodon/ready';

async function mountReactComponent(element: Element) {
  const componentName = element.getAttribute('data-admin-component');
  const stringProps = element.getAttribute('data-props');

  if (!stringProps) return;

  const componentProps = JSON.parse(stringProps) as object;

  const { default: AdminComponent } = await import(
    '@/mastodon/containers/admin_component'
  );

  const { default: Component } = (await import(
    `@/mastodon/components/admin/${componentName}`
  )) as { default: React.ComponentType };

  const root = createRoot(element);

  root.render(
    <AdminComponent>
      <Component {...componentProps} />
    </AdminComponent>,
  );
}

ready(() => {
  document.querySelectorAll('[data-admin-component]').forEach((element) => {
    void mountReactComponent(element);
  });
}).catch((reason) => {
  throw reason;
});
