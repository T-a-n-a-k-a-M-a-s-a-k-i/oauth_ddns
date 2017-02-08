class UserAccount< Sequel::Model
  plugin :validation_helpers
  plugin :schema
  unrestrict_primary_key

  unless table_exists?
    set_schema do
      String :uid, :primary_key => true
      String :provider
      String :nickname
    end

    create_table
  end
end
