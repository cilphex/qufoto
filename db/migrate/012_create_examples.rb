class CreateExamples < ActiveRecord::Migration
  def self.up
    create_table :examples do |t|
      t.integer :user_id
      t.integer :category
      t.integer :position
      t.string :location
      t.text :quote
      t.text :description

      t.timestamps
    end
    
    add_column :images, :example_id, :integer
  end

  def self.down
    Example.find(:all).each do |e|
      if e.image
        e.image.delete_s3
        e.image.destroy
      end
    end

    drop_table :examples
    remove_column :images, :example_id
  end
end
