class AddNewStuffToInfo < ActiveRecord::Migration
  def self.up
    add_column :infos, :toptext,            :string
    add_column :infos, :innerbgcolor,       :string, :null => false, :default => "000000"
    add_column :infos, :innerbgalpha,       :integer, :null => false, :default => 0
    add_column :infos, :bgtype,             :integer, :null => false, :default => 0
    add_column :infos, :bgpos,              :integer, :null => false, :default => 0
    add_column :infos, :bgrepeat,           :integer, :null => false, :default => 0
    add_column :infos, :bggradient,         :integer, :null => false, :default => 0
    add_column :infos, :bgimage,            :boolean
    add_column :infos, :link_clientaccess,  :string
    add_column :infos, :contact_info,       :text
  end

  def self.down
    remove_column :infos, :contact_info
    remove_column :infos, :link_clientaccess
    remove_column :infos, :bgimage
    remove_column :infos, :bggradient
    remove_column :infos, :bgrepeat
    remove_column :infos, :bgpos
    remove_column :infos, :bgtype
    remove_column :infos, :innerbgalpha
    remove_column :infos, :innerbgcolor
    remove_column :infos, :toptext
  end
end
