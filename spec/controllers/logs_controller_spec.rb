require 'rails_helper'

RSpec.describe LogsController, type: :controller do
  def http_login
    user = BASIC_AUTH[:name]
    pw = BASIC_AUTH[:password]
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
  end

  describe '#create' do
    it 'should record activity' do
      http_login

      expect(Activity.count).to eq 0

      log = <<-LOG
374 <190>1 2019-09-13T17:31:38.949095+00:00 host app worker.3 - I, [2019-09-13T17:31:38.948722 #4]  INFO -- : [ActiveJob] [DelayedPaperclip::ProcessJob] [eed7b9b4-88df-4552-aa0c-d16514ee46b4] Command :: convert -auto-orient '/tmp/cb803fb775c7cc0961b14131ec78bf5220190913-4-yrxt9e.jpg[0]' -auto-orient -resize \"3264x3264\" '/tmp/32ad8484817257547aadd8362e07625320190913-4-fjf26m'
377 <190>1 2019-09-13T17:32:44.283026+00:00 host app web.2 - I, [2019-09-13T17:32:40.048706 #36]  INFO -- : [2437a15b-3e78-4490-9452-2462011d3484] {\"method\":\"GET\",\"path\":\"/s/973/dashboard\",\"format\":\"html\",\"controller\":\"DashboardController\",\"action\":\"show\",\"status\":200,\"duration\":370.1,\"view\":88.66,\"db\":257.4,\"user\":\"flow.test@gmail.com\",\"school\":973,\"params\":{\"school_id\":\"973\"}}
242 <190>1 2019-09-13T17:32:44.283028+00:00 host app web.2 - I, [2019-09-13T17:32:40.579654 #36]  INFO -- : [20c78949-8157-4d91-813c-9f0e403ec636] [paperclip] deleting schools/1164/2019/posts/fa0ae86ec681c26cc853611ef43fb1f887d24289.original.jpg
467 <190>1 2019-09-13T17:32:44.283037+00:00 host app web.2 - I, [2019-09-13T17:32:40.612675 #36]  INFO -- : [3b45e5b2-7cc8-4fb4-8d2f-26c3587bc736] {\"method\":\"GET\",\"path\":\"/s/369/classrooms/2313/events.json\",\"format\":\"json\",\"controller\":\"EventsController\",\"action\":\"index\",\"status\":200,\"duration\":135.07,\"view\":0.25,\"db\":102.07,\"user\":\"kmc@gmail.com\",\"school\":369,\"params\":{\"since\":\"2019-09-13T13:31:36-04:00\",\"school_id\":\"369\",\"classroom_id\":\"2313\"}}
      LOG

      post :create, body: log

      expect(response).to be_successful

      activities = Activity.all
      expect(activities.length).to eq 2
      expect(activities[0].user.email).to eq('flow.test@gmail.com')
      expect(activities[0].name).to eq('GET /s/973/dashboard')
      expect(activities[0].school_id).to eq(973)
      expect(activities[1].user.email).to eq('kmc@gmail.com')
      expect(activities[1].name).to eq('GET /s/369/classrooms/2313/events.json')
      expect(activities[1].school_id).to eq(369)
    end
  end
end
