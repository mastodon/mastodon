require 'method_source'
require 'rspec'

def is_rbx?
  defined?(RUBY_ENGINE) && RUBY_ENGINE =~ /rbx/
end

def jruby?
  defined?(RUBY_ENGINE) && RUBY_ENGINE =~ /jruby/
end


module M
  def hello; :hello_module; end
end

$o = Object.new
def $o.hello; :hello_singleton; end

# A comment for hello

  # It spans two lines and is indented by 2 spaces
def hello; :hello; end

# a
# b
def comment_test1; end

 # a
 # b
def comment_test2; end

# a
#
# b
def comment_test3; end

# a

# b
def comment_test4; end


# a
  # b
    # c
# d
def comment_test5; end

# This is a comment for MyLambda
MyLambda = lambda { :lambda }
MyProc = Proc.new { :proc }


name = "name"

M.instance_eval <<-METHOD, __FILE__, __LINE__ + 1
  def hello_#{name}(*args)
    send_mesg(:#{name}, *args)
  end
METHOD

M.class_eval <<-METHOD, __FILE__, __LINE__ + 1
  def hello_#{name}(*args)
    send_mesg(:#{name}, *args)
  end
METHOD

# module_eval to DRY code up
#
M.module_eval <<-METHOD, __FILE__, __LINE__ + 1

  # module_eval is used here
  #
  def hi_#{name}
    @var = #{name}
  end
METHOD

# case where 2 methods are defined inside an _eval block
#
M.instance_eval <<EOF, __FILE__, __LINE__ + 1

  def #{name}_one()
    if 43
      44
    end
  end


  def #{name}_two()
    if 44
      45
    end
  end
EOF

# class_eval without filename and lineno + 1 parameter

M.class_eval "def #{name}_three; @tempfile.#{name}; end"

