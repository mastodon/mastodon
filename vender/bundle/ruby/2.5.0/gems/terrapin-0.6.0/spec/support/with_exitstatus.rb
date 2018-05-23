module WithExitstatus
  def with_exitstatus_returning(code)
    saved_exitstatus = $?.respond_to?(:exitstatus) ? $?.exitstatus : 0
    begin
      `ruby -e "exit #{code.to_i}"`
      yield
    ensure
      `ruby -e "exit #{saved_exitstatus.to_i}"`
    end
  end
end

