type HookGetter<P extends {}, Result> = (p: P) => Result;
type GetHookProps<H> = H extends HookGetter<infer P, any> ? P : never;
type GetHookResult<H> = H extends HookGetter<any, infer R> ? R : never;

export default function injectHook<
  Props extends Partial<{ [k in Name]: GetHookResult<Hook> }>,
  Hook extends HookGetter<any, any>,
  Name extends keyof Props
>(name: Name, getHook: Hook) {
  return function getComponent(
    component: React.FC<Props>
  ): React.FC<Omit<Props, Name> & GetHookProps<Hook>> {
    return function getComponentWithInjectedHook(p: Props) {
      const hook = getHook(p);
      return component({ [name]: hook, ...p } as any);
    };
  };
}