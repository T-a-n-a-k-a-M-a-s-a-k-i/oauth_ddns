class DNSService
  Name = Resolv::DNS::Name
  IN = Resolv::DNS::Resource::IN

  def self.run!
    RubyDNS::run_server(:listen => [[:udp, "0.0.0.0", 53],[:tcp, "0.0.0.0", 53]]) do
      match(/.*/, IN::A) do |transaction|
      end

      match(/.*/, IN::AAAA) do |transaction|
      end

      match(/.*/, IN::TXT) do |transaction|
      end

      otherwise do |transaction|
        transaction.fail!(:NXDomain)
      end
    end
  end
end
