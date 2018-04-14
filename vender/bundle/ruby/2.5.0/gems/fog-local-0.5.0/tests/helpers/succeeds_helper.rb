module Shindo
  class Tests
    def succeeds
      test('succeeds') do
        !!instance_eval(&Proc.new)
      end
    end
  end
end
