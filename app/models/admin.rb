class Admin
  attr_accessor :email, :name
  def initialize(email:, name:)
    self.email = email
    self.name = name
  end

  def self.authenticate(auth_hash:, session:)
    admin = new(email: auth_hash.info.email, name: auth_hash.info.name)
    raise NotAuthorizedError unless admin.transparent_classroom_employee?
    session[:current_user_email] = admin.email
    session[:current_user_name] = admin.name
    admin
  end

  def self.from_session(session:)
    new(email: session[:current_user_email], name: session[:current_user_name])
  end

  def self.logout(session:)
    session[:current_user_name] = nil
    session[:current_user_email] = nil
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
end
