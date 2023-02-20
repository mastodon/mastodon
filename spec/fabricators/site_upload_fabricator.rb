Fabricator(:site_upload) do
  file { Rails.root.join('spec', 'fabricators', 'assets', 'utah_teapot.png').open }
end
