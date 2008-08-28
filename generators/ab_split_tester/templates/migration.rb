class  CreateAbSplitTestHits < ActiveRecord::Migration
  def self.up
    create_table :ab_split_test_hits do |t|
      t.column :visitor_id, :string
      t.column :campaign_name, :string
      t.column :action, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table ab_split_test_hits
  end
end
