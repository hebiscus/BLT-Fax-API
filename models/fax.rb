class Fax 
  attr_reader :id, :file_path, :user_token
  attr_accessor :receiver_number, :status

  def initialize(id:, file_path:, receiver_number:, status:, user_token:)
    @id = id
    @file_path = file_path
    @receiver_number = receiver_number
    @status = status
    @user_token = user_token
    @created_at = Time.now
  end

  def to_h
    {
      id: @id,
      file_path: @file_path,
      receiver_number: @receiver_number,
      status: @status,
      created_at: @created_at,
      user_token: @user_token
    }
  end
end
