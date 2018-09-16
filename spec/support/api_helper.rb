module ApiHelper
  def json
    JSON.parse(response.body)
  rescue JSON::ParserError
    response.body
  end
end
