class AddPortfolioCounter < ActiveRecord::Migration
  def self.up
    add_column :users, :portfolios_count, :integer, :default => 0
    
    User.reset_column_information
    User.find(:all).each do |u|
      User.update_counters u.id, :portfolios_count => u.portfolios.length
    end
  end

  def self.down
    remove_column :users, :portfolios_count
  end
end
