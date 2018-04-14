module UnsettingExitstatus
  def assuming_no_processes_have_been_run
    class << $?
      undef_method :exitstatus
    end
  end
end
