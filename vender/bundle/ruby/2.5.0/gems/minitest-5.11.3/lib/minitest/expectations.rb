##
# It's where you hide your "assertions".
#
# Please note, because of the way that expectations are implemented,
# all expectations (eg must_equal) are dependent upon a thread local
# variable +:current_spec+. If your specs rely on mixing threads into
# the specs themselves, you're better off using assertions or the new
# _(value) wrapper. For example:
#
#     it "should still work in threads" do
#       my_threaded_thingy do
#         (1+1).must_equal 2         # bad
#         assert_equal 2, 1+1        # good
#         _(1 + 1).must_equal 2      # good
#         value(1 + 1).must_equal 2  # good, also #expect
#       end
#     end

module Minitest::Expectations

  ##
  # See Minitest::Assertions#assert_empty.
  #
  #    collection.must_be_empty
  #
  # :method: must_be_empty

  infect_an_assertion :assert_empty, :must_be_empty, :unary

  ##
  # See Minitest::Assertions#assert_equal
  #
  #    a.must_equal b
  #
  # :method: must_equal

  infect_an_assertion :assert_equal, :must_equal

  ##
  # See Minitest::Assertions#assert_in_delta
  #
  #    n.must_be_close_to m [, delta]
  #
  # :method: must_be_close_to

  infect_an_assertion :assert_in_delta, :must_be_close_to

  alias :must_be_within_delta :must_be_close_to # :nodoc:

  ##
  # See Minitest::Assertions#assert_in_epsilon
  #
  #    n.must_be_within_epsilon m [, epsilon]
  #
  # :method: must_be_within_epsilon

  infect_an_assertion :assert_in_epsilon, :must_be_within_epsilon

  ##
  # See Minitest::Assertions#assert_includes
  #
  #    collection.must_include obj
  #
  # :method: must_include

  infect_an_assertion :assert_includes, :must_include, :reverse

  ##
  # See Minitest::Assertions#assert_instance_of
  #
  #    obj.must_be_instance_of klass
  #
  # :method: must_be_instance_of

  infect_an_assertion :assert_instance_of, :must_be_instance_of

  ##
  # See Minitest::Assertions#assert_kind_of
  #
  #    obj.must_be_kind_of mod
  #
  # :method: must_be_kind_of

  infect_an_assertion :assert_kind_of, :must_be_kind_of

  ##
  # See Minitest::Assertions#assert_match
  #
  #    a.must_match b
  #
  # :method: must_match

  infect_an_assertion :assert_match, :must_match

  ##
  # See Minitest::Assertions#assert_nil
  #
  #    obj.must_be_nil
  #
  # :method: must_be_nil

  infect_an_assertion :assert_nil, :must_be_nil, :unary

  ##
  # See Minitest::Assertions#assert_operator
  #
  #    n.must_be :<=, 42
  #
  # This can also do predicates:
  #
  #    str.must_be :empty?
  #
  # :method: must_be

  infect_an_assertion :assert_operator, :must_be, :reverse

  ##
  # See Minitest::Assertions#assert_output
  #
  #    proc { ... }.must_output out_or_nil [, err]
  #
  # :method: must_output

  infect_an_assertion :assert_output, :must_output, :block

  ##
  # See Minitest::Assertions#assert_raises
  #
  #    proc { ... }.must_raise exception
  #
  # :method: must_raise

  infect_an_assertion :assert_raises, :must_raise, :block

  ##
  # See Minitest::Assertions#assert_respond_to
  #
  #    obj.must_respond_to msg
  #
  # :method: must_respond_to

  infect_an_assertion :assert_respond_to, :must_respond_to, :reverse

  ##
  # See Minitest::Assertions#assert_same
  #
  #    a.must_be_same_as b
  #
  # :method: must_be_same_as

  infect_an_assertion :assert_same, :must_be_same_as

  ##
  # See Minitest::Assertions#assert_silent
  #
  #    proc { ... }.must_be_silent
  #
  # :method: must_be_silent

  infect_an_assertion :assert_silent, :must_be_silent, :block

  ##
  # See Minitest::Assertions#assert_throws
  #
  #    proc { ... }.must_throw sym
  #
  # :method: must_throw

  infect_an_assertion :assert_throws, :must_throw, :block

  ##
  # See Minitest::Assertions#refute_empty
  #
  #    collection.wont_be_empty
  #
  # :method: wont_be_empty

  infect_an_assertion :refute_empty, :wont_be_empty, :unary

  ##
  # See Minitest::Assertions#refute_equal
  #
  #    a.wont_equal b
  #
  # :method: wont_equal

  infect_an_assertion :refute_equal, :wont_equal

  ##
  # See Minitest::Assertions#refute_in_delta
  #
  #    n.wont_be_close_to m [, delta]
  #
  # :method: wont_be_close_to

  infect_an_assertion :refute_in_delta, :wont_be_close_to

  alias :wont_be_within_delta :wont_be_close_to # :nodoc:

  ##
  # See Minitest::Assertions#refute_in_epsilon
  #
  #    n.wont_be_within_epsilon m [, epsilon]
  #
  # :method: wont_be_within_epsilon

  infect_an_assertion :refute_in_epsilon, :wont_be_within_epsilon

  ##
  # See Minitest::Assertions#refute_includes
  #
  #    collection.wont_include obj
  #
  # :method: wont_include

  infect_an_assertion :refute_includes, :wont_include, :reverse

  ##
  # See Minitest::Assertions#refute_instance_of
  #
  #    obj.wont_be_instance_of klass
  #
  # :method: wont_be_instance_of

  infect_an_assertion :refute_instance_of, :wont_be_instance_of

  ##
  # See Minitest::Assertions#refute_kind_of
  #
  #    obj.wont_be_kind_of mod
  #
  # :method: wont_be_kind_of

  infect_an_assertion :refute_kind_of, :wont_be_kind_of

  ##
  # See Minitest::Assertions#refute_match
  #
  #    a.wont_match b
  #
  # :method: wont_match

  infect_an_assertion :refute_match, :wont_match

  ##
  # See Minitest::Assertions#refute_nil
  #
  #    obj.wont_be_nil
  #
  # :method: wont_be_nil

  infect_an_assertion :refute_nil, :wont_be_nil, :unary

  ##
  # See Minitest::Assertions#refute_operator
  #
  #    n.wont_be :<=, 42
  #
  # This can also do predicates:
  #
  #    str.wont_be :empty?
  #
  # :method: wont_be

  infect_an_assertion :refute_operator, :wont_be, :reverse

  ##
  # See Minitest::Assertions#refute_respond_to
  #
  #    obj.wont_respond_to msg
  #
  # :method: wont_respond_to

  infect_an_assertion :refute_respond_to, :wont_respond_to, :reverse

  ##
  # See Minitest::Assertions#refute_same
  #
  #    a.wont_be_same_as b
  #
  # :method: wont_be_same_as

  infect_an_assertion :refute_same, :wont_be_same_as
end
