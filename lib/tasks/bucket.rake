task clean_requests: :environment do
  retention_period = 3.days.ago

  Request.delete_all  created_at: { '$lt' => retention_period }
  Response.delete_all created_at: { '$lt' => retention_period }
end

task :clean_buckets => :environment do
  retention_period = 3.months.ago

  Bucket.delete_all(last_request_at: { '$lt' => retention_period }, updated_at:  { '$lt' => retention_period } )

  Bucket.delete_all(last_request_at: nil, updated_at:  { '$lt' => retention_period } )
end
