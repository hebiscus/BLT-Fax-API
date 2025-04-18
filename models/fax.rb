class Fax 
  attr_reader :id, :file_path
  attr_accessor :receiver_number, :status

  def initialize(id:, file_path:, receiver_number:, status:)
    @id = id
    @file_path = file_path
    @receiver_number = receiver_number
    @status = status
    @created_at = Time.now
  end

  def to_h
    {
      id: @id,
      number: @number,
      file_path: @file_path,
      status: @status
    }
  end
end
