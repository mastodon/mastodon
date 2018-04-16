# Todo: s/tests/specs when migration is complete
def get_abs_path(*parts)
  File.join(File.expand_path('../../..', __FILE__), 'tests', *parts)
end

def data_path(*parts)
  get_abs_path('data', *parts)
end

def rackup_path(*parts)
  get_abs_path('rackups', *parts)
end

def webrick_path(*parts) rackup_path(*parts); end

def unicorn_path(*parts) rackup_path(*parts); end

def puma_path(*parts) rackup_path(*parts); end

def exec_path(*parts)
  get_abs_path('servers', *parts)
end
