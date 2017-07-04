module FixtureFiles
  def fixture_file_path(file_name = '')
    File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', file_name))
  end
end

RSpec.configure do |c|
  c.include FixtureFiles
end
