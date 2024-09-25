/* eslint-disable import/no-default-export */
declare module '*.avif' {
  const path: string;
  export default path;
}

declare module '*.gif' {
  const path: string;
  export default path;
}

declare module '*.jpg' {
  const path: string;
  export default path;
}

declare module '*.png' {
  const path: string;
  export default path;
}

declare module '*.svg' {
  const path: string;
  export default path;
}

declare module '*.svg?react' {
  import type React from 'react';

  interface SVGPropsWithTitle extends React.SVGProps<SVGSVGElement> {
    title?: string;
  }

  const ReactComponent: React.FC<SVGPropsWithTitle>;

  export default ReactComponent;
}

declare module '*.webp' {
  const path: string;
  export default path;
}
