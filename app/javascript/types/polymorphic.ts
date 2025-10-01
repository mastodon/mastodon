import { forwardRef } from 'react';
import type {
  ElementType,
  ComponentPropsWithRef,
  ForwardRefRenderFunction,
  ReactElement,
  Ref,
  ForwardRefExoticComponent,
} from 'react';

// This complicated type file is based on the following posts:
// - https://www.tsteele.dev/posts/react-polymorphic-forwardref
// - https://www.kripod.dev/blog/behind-the-as-prop-polymorphism-done-well/
// - https://github.com/radix-ui/primitives/blob/7101e7d6efb2bff13cc6761023ab85aeec73539e/packages/react/polymorphic/src/forwardRefWithAs.ts
// Whenever we upgrade to React 19 or later, we can remove all this because ref is a prop there.

// Utils
interface AsProp<As extends ElementType> {
  as?: As;
}
type PropsOf<As extends ElementType> = ComponentPropsWithRef<As>;

/**
 * Extract the element instance type (e.g. HTMLButtonElement) from ComponentPropsWithRef<As>:
 * - For intrinsic elements, look up in JSX.IntrinsicElements
 * - For components, infer from `ComponentPropsWithRef`
 */
type ElementRef<As extends ElementType> =
  As extends keyof React.JSX.IntrinsicElements
    ? React.JSX.IntrinsicElements[As] extends { ref?: Ref<infer Inst> }
      ? Inst
      : never
    : ComponentPropsWithRef<As> extends { ref?: Ref<infer Inst> }
      ? Inst
      : never;

/**
 * Merge additional props with intrinsic/element props for `as`.
 * Additional props win on conflicts.
 */
type PolymorphicProps<
  As extends ElementType,
  AdditionalProps extends object = object,
> = AdditionalProps &
  AsProp<As> &
  Omit<PropsOf<As>, keyof AdditionalProps | 'ref'>;

/**
 * Signature of a component created with `polymorphicForwardRef`.
 */
type PolymorphicWithRef<
  DefaultAs extends ElementType,
  AdditionalProps extends object = object,
> = <As extends ElementType = DefaultAs>(
  props: PolymorphicProps<As, AdditionalProps> & { ref?: Ref<ElementRef<As>> },
) => ReactElement | null;

/**
 * The type of `polymorphicForwardRef`.
 */
type PolyRefFunction = <
  DefaultAs extends ElementType,
  AdditionalProps extends object = object,
>(
  render: ForwardRefRenderFunction<
    ElementRef<DefaultAs>,
    PolymorphicProps<DefaultAs, AdditionalProps>
  >,
) => PolymorphicWithRef<DefaultAs, AdditionalProps> &
  ForwardRefExoticComponent<PolymorphicProps<DefaultAs, AdditionalProps>>;

/**
 * Polymorphic `forwardRef` function.
 */
export const polymorphicForwardRef = forwardRef as PolyRefFunction;
