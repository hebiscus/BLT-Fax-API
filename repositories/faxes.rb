require_relative "../models/fax"
require 'json'
require 'time'

module Repositories
  class Faxes
    FAXES_DB = './db/faxes.json'

    def all
      load_db.map { |attributes| build(**attributes) }
    end

    def all_pending
      all.select { |fax| fax.status == "pending"}
    end

    def find(id)
      attributes = load_db[id]
      attributes && build(**attributes)
    end

    def find_by_token(token)
      all.select { |fax| fax.user_token == token }
    end

    def update_pending
      faxes = load_db
      faxes.each do |fax|
        if fax["status"] == "pending"
          fax["status"] = ["sent", "failed"].sample
        end
      end
      save_faxes(faxes)
    end

    private

    def load_db
      File.exist?(FAXES_DB) ? JSON.parse(File.read(FAXES_DB)) : []
    end

    def save_faxes(faxes)
      File.write(FAXES_DB,  JSON.pretty_generate(faxes))
    end

    def build(**attributes)
      Fax.new(
        id: attributes["id"],
        file_path: attributes["file_path"],
        receiver_number: attributes["receiver_number"],
        status: attributes["status"],
        created_at: attributes["created_at"],
        user_token: attributes["user_token"]
      )
    end
  end
end
