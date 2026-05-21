class FirefoxConstraint
  def self.matches?(request)
    request.user_agent.to_s.include?("Firefox")
  end
end

class NonFirefoxConstraint
  def self.matches?(request)
    !request.user_agent.to_s.include?("Firefox")
  end
end