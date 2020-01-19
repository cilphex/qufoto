class AddEnabledToExample < ActiveRecord::Migration
  def self.up
    add_column :examples, :enabled, :boolean, :default => false
    add_column :examples, :name, :string
  end

  def self.down
    remove_column :examples, :enabled
    remove_column :examples, :name
  end
end
