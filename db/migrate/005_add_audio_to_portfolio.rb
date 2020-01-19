class AddAudioToPortfolio < ActiveRecord::Migration
  def self.up
    remove_column :infos, :portfolio_audio
    
    add_column :portfolios, :audio, :boolean, :default => false
    
    # Loop through all existing users, check for files on s3
    # and update the database as required.
    # This may take a while to run.
    User.find(:all).each do |u|
       # Loop over portfolios
       u.portfolios.each_with_index do |p,i|
         if AWS::S3::S3Object.exists?("portfolio_audio" + p.id.to_s + ".mp3", QBUCKET.to_s)
           u.portfolios[i].update_attribute(:audio, true)
         end
       end
    end  
  end

  def self.down
    remove_column :portfolios, :audio
    
    add_column :infos, :portfolio_audio, :boolean, :default => false
  end
  
end
