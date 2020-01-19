class AddStoryIdToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :interview_id, :integer
    add_column :images, :primary, :boolean, :default => 0
    change_column :images, :portfolio_id, :integer, :null => true, :default => nil
  end

  def self.down
    remove_column :images, :interview_id
    remove_column :images, :primary
    change_column :images, :portfolio_id, :integer, :null => false, :default => 0
  end
end
