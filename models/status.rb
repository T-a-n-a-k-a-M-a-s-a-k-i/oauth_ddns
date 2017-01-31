class Status < Sequel::Model
  plugin :validation_helpers
  plugin :schema
  unrestrict_primary_key

  unless table_exists?
    set_schema do
      foreign_key :provider, :key=>:provider, :table=>:providers, :on_delete=>:cascade, :type=>String
      foreign_key :record_type, :key=>:record_type, :table=>:record_types, :on_delete=>:cascade, :type=>String
      String :user_id
      String :record

      primary_key([:provider, :record_type, :user_id])
    end

    create_table
  end
end
