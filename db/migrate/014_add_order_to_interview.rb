class AddOrderToInterview < ActiveRecord::Migration
  def self.up
    add_column :interviews, :position, :integer
  end

  def self.down
    remove_column :interviews, :position, :integer
  end
end
