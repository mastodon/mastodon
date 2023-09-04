Fabricator(:site_upload) do
  file { File.open(File.join(Rails.root, 'spec', 'fabricators', 'assets', 'utah_teapot.png')) }
end
