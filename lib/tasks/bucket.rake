task :clean_requests => :environment do
  retention_period = 3.days.ago

  request.delete_all  created_at: { '$lt' => retention_period }
  response.delete_all created_at: { '$lt' => retention_period }
end

task :clean_buckets => :environment do
  retention_period = 1.week.ago

  Bucket.delete_all or: [created_at: { '$lt' => retention_period }, created_at: nil]
end
