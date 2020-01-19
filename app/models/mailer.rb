# The body method has special behavior. It takes a hash which generates 
# an instance variable named after each key in the hash containing the 
# value that that key points to.

class Mailer < ActionMailer::Base
  def comment(comment)
    recipients "service@qufoto.com"     #change this to service@photositesite.com if you see it works later
    from       comment.replyTo
    headers    "Reply-to" => "#{comment.replyTo}"
    subject    "Qufoto: Comment from #{comment.sender}"
    body       :sender => comment.sender, 
               :replyTo => comment.replyTo, 
               :body => comment.body
  end
  
  def message(comment)   # for individual PSS flash sites
    recipients  comment.recipient
    from        comment.replyTo
    headers     "Reply-to" => "#{comment.replyTo}"
    subject     "Your Website: Comment from #{comment.sender}"
    body        :sender => comment.sender,
                :replyTo => comment.replyTo,
                :body => comment.body
  end
  
  def domain_name(comment)
    recipients  "service@qufoto.com"
    from        comment.sender
    subject     "Qufoto: Domain Request"
    body        :body => comment.body
  end
  
  def refer_message(comment)
    recipients  comment.recipient
    from        "info@qufoto.com"
    subject     "Message from #{comment.sender}"
    body        :sender => comment.sender,
                :body => comment.body
  end
  
  def password_message(comment)
    recipients  comment.recipient
    from        "service@qufoto.com"
    headers     "Reply-to" => "service@qufoto.com"
    subject     "Username & Password reminder"
    body        :body => comment.body
  end
  
  def signup_email(name, email)
    recipients  email
    from        'service@qufoto.com'
    headers     'Reply-to' => 'service@qufoto.com'
    subject     'Welcome to Qufoto!'
    body        :name => name,
                :email => email
  end
  
  def welcome_email(comment)
    recipients  comment.recipient
    from        "service@qufoto.com"
    headers     "Reply-to" => "service@qufoto.com"
    subject     "Qufoto.com: Your new website"
    body        :body => comment.body.split('|')
  end
  
  def yay_referral(name, email, item_name)
    recipients  ["service@qufoto.com", "vavweb@gmail.com"]
    from        "service@qufoto.com"
    headers     "Reply-to" => "service@qufoto.com"
    subject     "Qufoto.com: New referral signup"
    body        :name => name,
                :email => email,
                :item_name => item_name
  end
end
