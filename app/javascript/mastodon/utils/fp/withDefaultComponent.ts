export default function withDefaultComponent<Props extends {}>(visible: (x: Props) => boolean) {
  return function (
    component: React.FC<Props>
  ): React.FC<Props & { defaultComponent?: React.ReactElement }> {
    return function isCondition(p) {
      const r = component(p);
      if (visible(p)) return r;
      else {
        return p.defaultComponent;
      }
    };
  };
}