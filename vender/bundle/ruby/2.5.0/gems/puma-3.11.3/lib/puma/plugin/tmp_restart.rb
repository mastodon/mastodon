require 'puma/plugin'

Puma::Plugin.create do
  def start(launcher)
    path = File.join("tmp", "restart.txt")

    orig = nil

    # If we can't write to the path, then just don't bother with this plugin
    begin
      File.write(path, "") unless File.exist?(path)
      orig = File.stat(path).mtime
    rescue SystemCallError
      return
    end

    in_background do
      while true
        sleep 2

        begin
          mtime = File.stat(path).mtime
        rescue SystemCallError
          # If the file has disappeared, assume that means don't restart
        else
          if mtime > orig
            launcher.restart
            break
          end
        end
      end
    end
  end
end
