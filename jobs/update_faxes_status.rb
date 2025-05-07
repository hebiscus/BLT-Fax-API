require_relative "../repositories/faxes"

File.open("/home/hebi/personal-projects/BLT-Fax-API/logs/cron_debug.log", "a") do |f|
  f.puts "[#{Time.now}] Script started"
end

Repositories::Faxes.new.update_pending
