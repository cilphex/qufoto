class AddPrivacyToPortfolio < ActiveRecord::Migration
  def self.up
    add_column :portfolios, :private, :boolean, :default => false
    add_column :portfolios, :password, :string
  end

  def self.down
    remove_column :portfolios, :password
    remove_column :portfolios, :private
  end
end
