# make human readable user agent detection simplier
module UserAgentDetection
  def ios_device?
    iphone? || ipad? || ipod?
  end

  def iphone?
    user_agent_detected('iphone')
  end

  def ipad?
    user_agent_detected('ipad')
  end

  def ipod?
    user_agent_detected('ipod')
  end

  def user_agent
    @user_agent ||= request.env['HTTP_USER_AGENT'].to_s.downcase
  end

  def user_agent_detected(name)
    !user_agent.index(name).nil?
  end
end
