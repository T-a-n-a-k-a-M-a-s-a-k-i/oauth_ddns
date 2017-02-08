class Status < Sequel::Model
  plugin :validation_helpers
  plugin :schema
  unrestrict_primary_key

  unless table_exists?
    set_schema do
      foreign_key :uid, :key=>:uid, :table=>:user_accounts, :on_delete=>:cascade, :type=>String
      foreign_key :record_type, :key=>:record_type, :table=>:record_types, :on_delete=>:cascade, :type=>String
      String :record

      primary_key([:uid, :record_type])
    end

    create_table
  end

  def self.update_status(params)
    DB.transaction do 
      RecordType.all.each do |items|
        status = self.find_or_create(
          :uid => params["uid"],
          :record_type => items.record_type
        )
        status.set(:record => params[items.record_type])
        status.save_changes(:raise_on_failure => true)
      end
    end
  end

  def self.delete_status(uid)
    DB.transaction do
      self.filter(:uid => uid).all.to_a.each do |items|
        items.delete
      end
    end
  end
end
