require "rspec"
require "bundler/setup"
require "oedipus"

Dir[File.expand_path("../support/**/*rb", __FILE__)].each { |f| require f }

RSpec.configure do |config|
  include Oedipus::TestHarness

  config.before(:each) do
    set_data_dir File.expand_path("../data", __FILE__)

    prepare_data_dirs
    write_sphinx_conf
    start_searchd
  end

  config.after(:each) do
    stop_searchd
  end
end
