require_relative "../models/fax"

module Repositories
  class Faxes
    FAXES_DB = './db/faxes.json'

    def all
      load_db.values.map { |attributes| build(**attributes) }
    end

    def find(id)
      attributes = load_db[id]
      attributes && build(**attributes)
    end

    def find_by_token(token)
      all.select { |fax| fax.user_token == token }
    end

    private

    def load_db
      File.exist?(FAXES_DB) ? JSON.parse(File.read(FAXES_DB)) : {}
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
