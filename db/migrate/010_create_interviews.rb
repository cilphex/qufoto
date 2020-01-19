class CreateInterviews < ActiveRecord::Migration
  def self.up
    create_table :interviews do |t|
      t.string :interviewer
      t.string :interviewee
      t.string :url
      t.string :link
      t.text :body
      t.text :caption
      t.text :bio
      t.integer :images_count
      t.integer :photographer_picid, :default => 0
      t.boolean :enabled, :default => false

      t.timestamp :created, :null => false
      t.timestamp :last_edit, :null => false
    end
  end

  def self.down
    # add something that deletes all the images attached to each interview here
    drop_table :interviews
  end
end
