namespace :db do
  desc "repair database to prevent Mongo::Error::OperationFailure (quota exceeded (12501))"
  task repair: :environment do
    Mongoid.default_client.command repairDatabase: 1
  end
end