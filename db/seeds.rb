users = 40.times.map { |id|
  User.create! id: id
}

school_ids = (30..70).to_a

methods = %w[GET GET GET GET GET POST PUT DELETE]

seconds = (0..10).to_a + [1000]

time = 1000.days.ago

1000.times do
  Activity.log users.sample,
               school_ids.sample,
               "#{methods.sample} /some/other/path",
               (time += seconds.sample).iso8601
end
