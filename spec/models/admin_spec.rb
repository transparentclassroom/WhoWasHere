require "rails_helper"

RSpec.describe Admin, type: :model do
  def build_info(email: nil, name: nil)
    OpenStruct.new(email: email, name: name)
  end

  describe "::authenticate(info:, session:)" do
    let(:session) { {} }
    it "returns an Admin when the info has an @transparentclassroom.com email" do
      info = build_info(name: "user name", email: "user@transparentclassroom.com")\

      admin = Admin.authenticate(info: info, session: session)

      aggregate_failures do
        expect(admin.name).to eql("user name")
        expect(admin.email).to eql("user@transparentclassroom.com")
      end
    end

    it "throws an error if the user email does not end with @transparentclassroom.com" do
      info = build_info(name: "user name", email: "user@example.com")

      expect {
        Admin.authenticate(info: info, session: session)
      }.to raise_error(NotAuthorizedError)
    end

    it "remembers the admin in the session" do
      info = build_info(email: "user@transparentclassroom.com", name: "user name")

      admin = Admin.authenticate(info: info, session: session)
      expect(Admin.from_session(session: session)).to eql(admin)
    end
  end

  describe "::logout(info:, session:)" do
    it "cleans out the admin data from the session" do
      session = (initial_session = {other_session_data: "oh-hey"}).dup
      info = build_info(email: "user@transparentclassroom.com", name: "user name")
      Admin.authenticate(info: info, session: session)

      Admin.logout(session: session)

      aggregate_failures do
        expect(Admin.from_session(session: session)).not_to be_authenticated
        expect(session).to eql(initial_session)
      end
    end
  end

  describe "::from_session(session:)" do
    it "returns an unauthenticated user when there is no current_user_email" do
      admin = Admin.from_session(session: {})
      expect(admin).not_to be_authenticated
    end

    it "returns an authenticated user when there is a current_user_email" do
      admin = Admin.from_session(session: {current_user_email: "person@example.com"})
      expect(admin).to be_authenticated
    end
  end
end
