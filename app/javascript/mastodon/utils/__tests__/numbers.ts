import { DECIMAL_UNITS, toShortNumber } from '../numbers';

interface TableRow {
  input: number;
  base: number;
  unit: number;
  digits: number;
}

describe.each`
  input             | base         | unit                      | digits
  ${10_000_000}     | ${10}        | ${DECIMAL_UNITS.MILLION}  | ${0}
  ${2_789_123}      | ${2.789123}  | ${DECIMAL_UNITS.MILLION}  | ${1}
  ${12_345_789}     | ${12.345789} | ${DECIMAL_UNITS.MILLION}  | ${0}
  ${10_000_000_000} | ${10}        | ${DECIMAL_UNITS.BILLION}  | ${0}
  ${12}             | ${12}        | ${DECIMAL_UNITS.ONE}      | ${0}
  ${123}            | ${123}       | ${DECIMAL_UNITS.ONE}      | ${0}
  ${1234}           | ${1.234}     | ${DECIMAL_UNITS.THOUSAND} | ${1}
  ${6666}           | ${6.666}     | ${DECIMAL_UNITS.THOUSAND} | ${1}
`('toShortNumber', ({ input, base, unit, digits }: TableRow) => {
  test(`correctly formats ${input}`, () => {
    expect(toShortNumber(input)).toEqual([base, unit, digits]);
  });
});
