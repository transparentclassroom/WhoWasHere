require 'rails_helper'

RSpec.describe LogParser do
  let(:parser) { LogParser.new }

  describe '#parse_line' do
    it 'should parse' do
      log = <<-LOG
289 <190>1 2019-09-13T17:31:38.888083+00:00 host app worker.3 - I, [2019-09-13T17:31:38.547618 #4]  INFO -- : [ActiveJob] [DelayedPaperclip::ProcessJob] [f22e2e8c-58e4-4151-b2cc-df72d4fd1a1b] [paperclip] saving schools/373/2019/posts/efdec064b48657d383fed1eef42aaf69654771df.medium_square.jpg
280 <190>1 2019-09-13T17:31:38.888085+00:00 host app worker.3 - I, [2019-09-13T17:31:38.590313 #4]  INFO -- : [ActiveJob] [DelayedPaperclip::ProcessJob] [f22e2e8c-58e4-4151-b2cc-df72d4fd1a1b] [paperclip] saving schools/373/2019/posts/efdec064b48657d383fed1eef42aaf69654771df.text.jpg
281 <190>1 2019-09-13T17:31:38.888087+00:00 host app worker.3 - I, [2019-09-13T17:31:38.712898 #4]  INFO -- : [ActiveJob] [DelayedPaperclip::ProcessJob] [f22e2e8c-58e4-4151-b2cc-df72d4fd1a1b] [paperclip] saving schools/373/2019/posts/efdec064b48657d383fed1eef42aaf69654771df.large.jpg
314 <190>1 2019-09-13T17:31:38.888090+00:00 host app worker.3 - I, [2019-09-13T17:31:38.793035 #4]  INFO -- : [ActiveJob] [DelayedPaperclip::ProcessJob] [f22e2e8c-58e4-4151-b2cc-df72d4fd1a1b] Performed DelayedPaperclip::ProcessJob (Job ID: f22e2e8c-58e4-4151-b2cc-df72d4fd1a1b) from DelayedJob(paperclip) in 5714.23ms
316 <190>1 2019-09-13T17:31:38.888092+00:00 host app worker.3 - [Worker(host:07d519a5-bd8f-4b1d-bea4-647e7d5f7f74 pid:4)] Job DelayedPaperclip::ProcessJob [f22e2e8c-58e4-4151-b2cc-df72d4fd1a1b] from DelayedJob(paperclip) with arguments: [\"Post\", 16013002, \"photo\"] (id=19830701) (queue=paperclip) COMPLETED after 5.7279
388 <190>1 2019-09-13T17:31:38.888095+00:00 host app worker.3 - I, [2019-09-13T17:31:38.805841 #4]  INFO -- : 2019-09-13T17:31:38+0000: [Worker(host:07d519a5-bd8f-4b1d-bea4-647e7d5f7f74 pid:4)] Job DelayedPaperclip::ProcessJob [f22e2e8c-58e4-4151-b2cc-df72d4fd1a1b] from DelayedJob(paperclip) with arguments: [\"Post\", 16013002, \"photo\"] (id=19830701) (queue=paperclip) COMPLETED after 5.7279
301 <190>1 2019-09-13T17:31:38.888097+00:00 host app worker.3 - [Worker(host:07d519a5-bd8f-4b1d-bea4-647e7d5f7f74 pid:4)] Job DelayedPaperclip::ProcessJob [eed7b9b4-88df-4552-aa0c-d16514ee46b4] from DelayedJob(paperclip) with arguments: [\"Post\", 16013014, \"photo\"] (id=19830712) (queue=paperclip) RUNNING
373 <190>1 2019-09-13T17:31:38.888099+00:00 host app worker.3 - I, [2019-09-13T17:31:38.809731 #4]  INFO -- : 2019-09-13T17:31:38+0000: [Worker(host:07d519a5-bd8f-4b1d-bea4-647e7d5f7f74 pid:4)] Job DelayedPaperclip::ProcessJob [eed7b9b4-88df-4552-aa0c-d16514ee46b4] from DelayedJob(paperclip) with arguments: [\"Post\", 16013014, \"photo\"] (id=19830712) (queue=paperclip) RUNNING
344 <190>1 2019-09-13T17:31:38.888100+00:00 host app worker.3 - I, [2019-09-13T17:31:38.810452 #4]  INFO -- : [ActiveJob] [DelayedPaperclip::ProcessJob] [eed7b9b4-88df-4552-aa0c-d16514ee46b4] Performing DelayedPaperclip::ProcessJob (Job ID: eed7b9b4-88df-4552-aa0c-d16514ee46b4) from DelayedJob(paperclip) with arguments: \"Post\", 16013014, \"photo\"
359 <190>1 2019-09-13T17:31:38.888102+00:00 host app worker.3 - I, [2019-09-13T17:31:38.813664 #4]  INFO -- : [ActiveJob] [DelayedPaperclip::ProcessJob] [eed7b9b4-88df-4552-aa0c-d16514ee46b4] [paperclip] copying schools/373/2019/posts/bdd0750632bac3c31fc7b06aafc8846a9622e084.original.jpg to local file /tmp/96898df36d635f954bec4256af13594220190913-4-1kawoq7.jpg
275 <190>1 2019-09-13T17:31:38.888104+00:00 host app worker.3 - I, [2019-09-13T17:31:38.887471 #4]  INFO -- : [ActiveJob] [DelayedPaperclip::ProcessJob] [eed7b9b4-88df-4552-aa0c-d16514ee46b4] Command :: file -b --mime '/tmp/96898df36d635f954bec4256af13594220190913-4-ajj9q3.jpg'
320 <190>1 2019-09-13T17:31:38.894329+00:00 host app worker.3 - I, [2019-09-13T17:31:38.894098 #4]  INFO -- : [ActiveJob] [DelayedPaperclip::ProcessJob] [eed7b9b4-88df-4552-aa0c-d16514ee46b4] Command :: identify -format '%wx%h,%[exif:orientation]' '/tmp/cb803fb775c7cc0961b14131ec78bf5220190913-4-yrxt9e.jpg[0]' 2>/dev/null
283 <190>1 2019-09-13T17:31:38.939797+00:00 host app worker.3 - I, [2019-09-13T17:31:38.939440 #4]  INFO -- : [ActiveJob] [DelayedPaperclip::ProcessJob] [eed7b9b4-88df-4552-aa0c-d16514ee46b4] Command :: identify -format %m '/tmp/cb803fb775c7cc0961b14131ec78bf5220190913-4-yrxt9e.jpg[0]'
374 <190>1 2019-09-13T17:31:38.949095+00:00 host app worker.3 - I, [2019-09-13T17:31:38.948722 #4]  INFO -- : [ActiveJob] [DelayedPaperclip::ProcessJob] [eed7b9b4-88df-4552-aa0c-d16514ee46b4] Command :: convert -auto-orient '/tmp/cb803fb775c7cc0961b14131ec78bf5220190913-4-yrxt9e.jpg[0]' -auto-orient -resize \"3264x3264\" '/tmp/32ad8484817257547aadd8362e07625320190913-4-fjf26m'
377 <190>1 2019-09-13T17:32:44.283026+00:00 host app web.2 - I, [2019-09-13T17:32:40.048706 #36]  INFO -- : [2437a15b-3e78-4490-9452-2462011d3484] {\"method\":\"GET\",\"path\":\"/s/973/dashboard\",\"format\":\"html\",\"controller\":\"DashboardController\",\"action\":\"show\",\"status\":200,\"duration\":370.1,\"view\":88.66,\"db\":257.4,\"user\":\"floey620@gmail.com\",\"school\":973,\"params\":{\"school_id\":\"973\"}}
242 <190>1 2019-09-13T17:32:44.283028+00:00 host app web.2 - I, [2019-09-13T17:32:40.579654 #36]  INFO -- : [20c78949-8157-4d91-813c-9f0e403ec636] [paperclip] deleting schools/1164/2019/posts/fa0ae86ec681c26cc853611ef43fb1f887d24289.original.jpg
247 <190>1 2019-09-13T17:32:44.283030+00:00 host app web.2 - I, [2019-09-13T17:32:40.595389 #36]  INFO -- : [20c78949-8157-4d91-813c-9f0e403ec636] [paperclip] deleting schools/1164/2019/posts/fa0ae86ec681c26cc853611ef43fb1f887d24289.medium_square.jpg
467 <190>1 2019-09-13T17:32:44.283037+00:00 host app web.2 - I, [2019-09-13T17:32:40.612675 #36]  INFO -- : [3b45e5b2-7cc8-4fb4-8d2f-26c3587bc736] {\"method\":\"GET\",\"path\":\"/s/369/classrooms/2313/events.json\",\"format\":\"json\",\"controller\":\"EventsController\",\"action\":\"index\",\"status\":200,\"duration\":135.07,\"view\":0.25,\"db\":102.07,\"user\":\"kmcintosh@guidepostmontessori.com\",\"school\":369,\"params\":{\"since\":\"2019-09-13T13:31:36-04:00\",\"school_id\":\"369\",\"classroom_id\":\"2313\"}}
238 <190>1 2019-09-13T17:32:44.283039+00:00 host app web.2 - I, [2019-09-13T17:32:40.620812 #36]  INFO -- : [20c78949-8157-4d91-813c-9f0e403ec636] [paperclip] deleting schools/1164/2019/posts/fa0ae86ec681c26cc853611ef43fb1f887d24289.text.jpg
239 <190>1 2019-09-13T17:32:44.283040+00:00 host app web.2 - I, [2019-09-13T17:32:40.640495 #36]  INFO -- : [20c78949-8157-4d91-813c-9f0e403ec636] [paperclip] deleting schools/1164/2019/posts/fa0ae86ec681c26cc853611ef43fb1f887d24289.large.jpg
424 <190>1 2019-09-13T17:32:44.283042+00:00 host app web.2 - I, [2019-09-13T17:32:40.781473 #36]  INFO -- : [20c78949-8157-4d91-813c-9f0e403ec636] {\"method\":\"DELETE\",\"path\":\"/s/1164/posts/16011840.json\",\"format\":\"json\",\"controller\":\"PostsController\",\"action\":\"destroy\",\"status\":200,\"duration\":396.78,\"view\":0.39,\"db\":210.39,\"user\":\"valentina.marjin@mcs-nobleton.com\",\"school\":1164,\"params\":{\"school_id\":\"1164\",\"id\":\"16011840\"}}
610 <190>1 2019-09-13T17:32:44.283044+00:00 host app web.2 - I, [2019-09-13T17:32:41.180058 #36]  INFO -- : [8a52ea83-ff12-4dc6-a6a2-9cffa1895a36] {\"method\":\"PUT\",\"path\":\"/s/370/classrooms/1060/levels.json\",\"format\":\"json\",\"controller\":\"Classrooms::LevelsController\",\"action\":\"update\",\"status\":200,\"duration\":142.59,\"view\":0.24,\"db\":100.02,\"user\":\"gaustin@guidepostmontessori.com\",\"school\":370,\"params\":{\"changes\":{\"251944\":{\"21345\":{\"id\":5743475,\"planned_position\":3,\"planned_date\":\"2019-09-11\",\"note\":\"\",\"planned\":true}}},\"log\":\"lesson-plan-save-lesson-card\",\"school_id\":\"370\",\"classroom_id\":\"1060\",\"level\":{}}}
386 <190>1 2019-09-13T17:32:44.283045+00:00 host app web.2 - I, [2019-09-13T17:32:41.565847 #36]  INFO -- : [7c03015c-8f96-4ec4-a179-d89824e167a9] {\"method\":\"GET\",\"path\":\"/s/1521/dashboard\",\"format\":\"html\",\"controller\":\"DashboardController\",\"action\":\"show\",\"status\":200,\"duration\":263.93,\"view\":59.97,\"db\":177.33,\"user\":\"abaranwal@deloitte.com\",\"school\":1521,\"params\":{\"school_id\":\"1521\"}}
      LOG
    end

    it 'should parse json and return it along w/ the date' do
      log = "467 <190>1 2019-09-13T17:32:44.283037+00:00 host app web.2 - I, [2019-09-13T17:32:40.612675 #36]  INFO -- : [3b45e5b2-7cc8-4fb4-8d2f-26c3587bc736] {\"method\":\"GET\",\"path\":\"/s/369/classrooms/2313/events.json\",\"format\":\"json\",\"controller\":\"EventsController\",\"action\":\"index\",\"status\":200,\"duration\":135.07,\"view\":0.25,\"db\":102.07,\"user\":\"kmcintosh@guidepostmontessori.com\",\"school\":369,\"params\":{\"since\":\"2019-09-13T13:31:36-04:00\",\"school_id\":\"369\",\"classroom_id\":\"2313\"}}"
      json = { 'method' => 'GET',
               'path' => '/s/369/classrooms/2313/events.json',
               'format' => 'json',
               'controller' => 'EventsController',
               'action' => 'index',
               'status' => 200,
               'duration' => 135.07,
               'view' => 0.25,
               'db' => 102.07,
               'user' => 'kmcintosh@guidepostmontessori.com',
               'school' => 369,
               'params' => { 'since' => '2019-09-13T13:31:36-04:00', 'school_id' => '369', 'classroom_id' => '2313' } }
      expec(parser.parse_line(log)).to eq(json)
      expec(parser.last_time).to eq('2019-09-13T17:32:44.283037+00:00')
    end

    it 'should ignore invalid lines' do
      log = "289 <190>1 2019-09-13T17:31:38.888083+00:00 host app worker.3 - I, [2019-09-13T17:31:38.547618 #4]  INFO -- : [ActiveJob] [DelayedPaperclip::ProcessJob] [f22e2e8c-58e4-4151-b2cc-df72d4fd1a1b] [paperclip] saving schools/373/2019/posts/efdec064b48657d383fed1eef42aaf69654771df.medium_square.jpg"
      expec(parser.parse_line(log)).to eq nil
      log = "316 <190>1 2019-09-13T17:31:38.888092+00:00 host app worker.3 - [Worker(host:07d519a5-bd8f-4b1d-bea4-647e7d5f7f74 pid:4)] Job DelayedPaperclip::ProcessJob [f22e2e8c-58e4-4151-b2cc-df72d4fd1a1b] from DelayedJob(paperclip) with arguments: [\"Post\", 16013002, \"photo\"] (id=19830701) (queue=paperclip) COMPLETED after 5.7279"
      expec(parser.parse_line(log)).to eq nil
      log = "242 <190>1 2019-09-13T17:32:44.283028+00:00 host app web.2 - I, [2019-09-13T17:32:40.579654 #36]  INFO -- : [20c78949-8157-4d91-813c-9f0e403ec636] [paperclip] deleting schools/1164/2019/posts/fa0ae86ec681c26cc853611ef43fb1f887d24289.original.jpg"
      expec(parser.parse_line(log)).to eq nil
    end
  end
end
