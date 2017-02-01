class RecordType < Sequel::Model
  plugin :validation_helpers
  plugin :schema
  unrestrict_primary_key

  unless table_exists?
    set_schema do
      String :record_type, :primary_key => true
    end

    create_table

    ["ipv4_address", "txt"].each do |record_type|
      self.insert(:record_type => record_type)
    end
  end
end
