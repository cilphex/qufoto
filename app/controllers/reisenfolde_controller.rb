class ReisenfoldeController < ApplicationController
  layout "reisenfolde"
  
  def index
  end
  
  def projects
  end
  
  def people
  end
  
  def blog
  end
  
  def contact
  end
  
  def deliver_message
    comment = Comment.new do |c|
      c.recipient = "craig@reisenfolde.com"
      c.sender = params['name']
      c.replyTo = params['email']
      c.body = params['body']
    end
    comment.save
    begin
      Mailer.deliver_message(comment)
      render :text => "<h3>MESSAGE SENT</h3>"
    rescue Exception
      render :text => "<h3>MESSAGE FAILED</h3>"
    end
  end
end
