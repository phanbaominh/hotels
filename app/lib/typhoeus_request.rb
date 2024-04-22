class TyphoeusRequest
  def self.build(url, timeout: 3)
    request = Typhoeus::Request.new(
      url, timeout: timeout.to_i
    )

    request.on_complete do |response|
      if response.success?
        yield(response, nil)
      elsif response.timed_out?
        yield(response, "got a time out")
      elsif response.code == 0
        yield(response, response.return_message)
      else
        yield(response, "HTTP request failed with " + response.code.to_s)
      end
    end
    request
  end
end
