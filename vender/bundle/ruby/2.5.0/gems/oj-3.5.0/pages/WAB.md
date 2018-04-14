# WAB mode

The `:wab` mode ignores all options except the indent option. Performance of
this mode is slightly faster than the :strict and :null modes. It is included
to support the [WABuR](https://github.com/ohler55/wabur) project.

Options other than the indentation are not supported since the encoding and
formats are defined by the API that is used to encode data being passed from
one components in a WAB system and allowing an option that would break the
data exchange is best not supported.

The mode encodes like the strict mode except the URI, Time, WAB::UUID, and
BigDecimal are supported.
