class AddUploadedAssetsRecordToInfos < ActiveRecord::Migration
  def self.up
    add_column :infos, :audio, :boolean, :default => false
    add_column :infos, :banner, :boolean, :default => false
    add_column :infos, :biopic, :boolean, :default => false
    add_column :infos, :favicon, :boolean, :default => false
    add_column :infos, :portfolio_audio, :boolean, :default => false
    add_column :infos, :resume, :boolean, :default => false
    add_column :infos, :splash, :boolean, :default => false
    
    # Loop through all existing users, check for files on s3
    # and update the database as required.
    # This may take a while to run.
    User.find(:all).each do |u|
       if AWS::S3::S3Object.exists?("audio" + u.id.to_s + ".mp3", QBUCKET.to_s)
         u.info.update_attribute(:audio, true)
       end
       if AWS::S3::S3Object.exists?("banner" + u.id.to_s + ".jpg", QBUCKET.to_s)
         u.info.update_attribute(:banner, true)
       end
       if AWS::S3::S3Object.exists?("biopic" + u.id.to_s + ".jpg", QBUCKET.to_s)
         u.info.update_attribute(:biopic, true)
       end
       if AWS::S3::S3Object.exists?("favicon" + u.id.to_s + ".ico", QBUCKET.to_s)
         u.info.update_attribute(:favicon, true)
       end
       if AWS::S3::S3Object.exists?("resume" + u.id.to_s + ".pdf", QBUCKET.to_s)
         u.info.update_attribute(:resume, true)
       end
       if AWS::S3::S3Object.exists?("splash" + u.id.to_s + ".jpg", QBUCKET.to_s)
         u.info.update_attribute(:splash, true)
       end
       # Loop over portfolios. Commented out as now moved to 004.
       # u.portfolios.each do |p|
       #   if AWS::S3::S3Object.exists?("portfolio_audio" + p.id.to_s + ".mp3", QBUCKET.to_s)
       #     u.info.update_attribute(:portfolio_audio, true)
       #   end
       # end
    end
    
  end

  def self.down
    remove_column :infos, :audio
    remove_column :infos, :banner
    remove_column :infos, :biopic
    remove_column :infos, :favicon
    remove_column :infos, :portfolio_audio
    remove_column :infos, :resume
    remove_column :infos, :splash
  end
end
