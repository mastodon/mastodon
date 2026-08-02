import { createPortal } from 'react-dom';

interface PortalProps {
  /**
   * The element to render the Portal's children into.
   * Must be an object, e.g. the result of a getElementById() call.
   * Set to `null` to render the children in place,
   * i.e. effectively disable the Portal's functionality
   */
  readonly container?: HTMLElement | SVGElement | null;
  readonly children?: React.ReactNode;
}

export const Portal: React.FC<PortalProps> = ({
  container,
  children,
}: PortalProps) => {
  if (container === null) return children;

  return createPortal(children, container ?? document.body);
};
