task :clean_requests => :environment do
  retention_period = 3.days.ago

  Request.delete_all  created_at: { '$lt' => retention_period }
  Response.delete_all created_at: { '$lt' => retention_period }
end
