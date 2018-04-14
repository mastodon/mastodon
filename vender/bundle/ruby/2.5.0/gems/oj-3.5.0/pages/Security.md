# Security and Optimization

Two settings in Oj are useful for parsing but do expose a vulnerability if used
from an untrusted source. Symbolized keys can cause memory to be filled with
previous versions of ruby. Ruby 2.1 and below does not garbage collect
Symbols. The same is true for auto defining classes in all versions of ruby;
memory will also be exhausted if too many classes are automatically
defined. Auto defining is a useful feature during development and from trusted
sources but it allows too many classes to be created in the object load mode and
auto defined is used with an untrusted source. The `Oj.strict_load()` method
sets and uses the most strict and safest options. It should be used by
developers who find it difficult to understand the options available in Oj.

The options in Oj are designed to provide flexibility to the developer. This
flexibility allows Objects to be serialized and deserialized. No methods are
ever called on these created Objects but that does not stop the developer from
calling methods on them. As in any system, check your inputs before working with
them. Taking an arbitrary `String` from a user and evaluating it is never a good
idea from an unsecure source. The same is true for `Object` attributes as they
are not more than `String`s. Always check inputs from untrusted sources.
