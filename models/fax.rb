class Fax 
  attr_reader :id, :file_path
  attr_accessor :number, :status

  def initialize(id:, file_path:, number:, status:)
    @id = id
    @file_path = file_path
    @number = number
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
