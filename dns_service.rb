class DNSService
  Name = Resolv::DNS::Name
  IN = Resolv::DNS::Resource::IN

  def self.get_status_by_dns_query(transaction, record_type)
    Status.join(:user_accounts).filter(
      :nickname => transaction.name.split(".").at(0),
      :provider => transaction.name.split(".").at(1),
      :record_type => record_type
    ).first
  end

  def self.run!
    RubyDNS::run_server(:listen => [[:udp, "0.0.0.0", 53],[:tcp, "0.0.0.0", 53]]) do
      match(/\.#{Settings.ddns_domain}$/, IN::A) do |transaction|
        ipv4_status = self.get_status_by_dns_query(transaction, "ipv4_address")

        if ipv4_status
          transaction.respond!(ipv4_status.record, resource_class: IN::A, ttl: 1)
        else
          transaction.fail!(:NXDomain)
        end
      end

      match(/\.#{Settings.ddns_domain}$/, IN::TXT) do |transaction|
        txt_status = self.get_status_by_dns_query(transaction, "txt")

        if txt_status
          transaction.respond!(txt_status.record, resource_class: IN::TXT, ttl: 1)
        else
          transaction.fail!(:NXDomain)
        end
      end

      otherwise do |transaction|
        transaction.fail!(:NXDomain)
      end
    end
  end
end
