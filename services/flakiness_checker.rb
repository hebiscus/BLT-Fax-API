class FlakinessChecker
  def self.should_fail?
    rand < 0.3
  end
end
