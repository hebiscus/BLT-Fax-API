module Authentication
  class TokenValidator
    def valid?(token)
      tokens = JSON.parse(File.read("./auth/tokens.json"))
      tokens.include?(token)
    end
  end
end
