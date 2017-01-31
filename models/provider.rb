class Provider < Sequel::Model
  plugin :validation_helpers
  plugin :schema
  unrestrict_primary_key

  unless table_exists?
    set_schema do
      String :provider, :primary_key => true
    end

    create_table
  end
end
