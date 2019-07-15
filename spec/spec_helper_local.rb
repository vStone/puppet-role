if ENV['PUPPET_DEBUG']
  RSpec.configure do |conf|
    conf.before(:each) do
      Puppet::Util::Log.level = :debug
      Puppet::Util::Log.newdestination(:console)
    end
  end
end
