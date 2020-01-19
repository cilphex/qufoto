class AddImagesCount < ActiveRecord::Migration
  def self.up
    add_column :portfolios, :images_count, :integer, :default => 0
    
    Portfolio.reset_column_information
    Portfolio.find(:all).each do |p|
      Portfolio.update_counters p.id, :images_count =>  p.images.length
    end
  end

  def self.down
    remove_column :portfolios, :images_count
  end
end
