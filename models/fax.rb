class Fax
  attr_reader :id, :file_path, :user_token, :created_at
  attr_accessor :receiver_number, :status

  def initialize(id:, file_path:, receiver_number:, status:, user_token:, created_at: Time.now)
    @id = id
    @file_path = file_path
    @receiver_number = receiver_number
    @status = status
    @user_token = user_token
    @created_at = created_at
  end

  def content
    File.read(@file_path) if @file_path && File.exist?(@file_path)
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

  def to_h_with_content
    to_h.merge(content: content)
  end
end
