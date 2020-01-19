class AddEditableTabs < ActiveRecord::Migration
  def self.up
    add_column :infos, :link_portfolios,  :string, :limit => 30
    add_column :infos, :link_multimedia,  :string, :limit => 30
    add_column :infos, :link_biography,   :string, :limit => 30
    add_column :infos, :link_contact,     :string, :limit => 30
    add_column :infos, :link_resume,      :string, :limit => 30
  end

  def self.down
    remove_column :infos, :link_portfolios
    remove_column :infos, :link_multimedia
    remove_column :infos, :link_biography
    remove_column :infos, :link_contact
    remove_column :infos, :link_resume
  end
end
