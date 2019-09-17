class Admin
  attr_accessor :email, :name
  def initialize(email:, name:)
    self.email = email
    self.name = name
  end

  def self.authenticate(info:, session:)
    admin = new(email: info.email, name: info.name)
    raise NotAuthorizedError unless admin.transparent_classroom_employee?
    session[:current_user_email] = admin.email
    session[:current_user_name] = admin.name
    admin
  end

  def self.from_session(session:)
    if session[:current_user_email]
      new(email: session[:current_user_email], name: session[:current_user_name])
    else
      UnauthenticatedAdmin.new
    end
  end

  def self.logout(session:)
    session.delete(:current_user_name)
    session.delete(:current_user_email)
  end

  def transparent_classroom_employee?
    email.ends_with?("@transparentclassroom.com")
  end

  def hash
    [name, email].hash
  end

  def ==(other)
    name == other.name && email == other.email
  end

  def eql?(other)
    self == other
  end

  def authenticated?
    true
  end
end
