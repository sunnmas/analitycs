module ApiHelper
  def global_url(url)
    return '' if url.blank?
    host = $API_HOST
    host << '/' if url[0] != '/'
    "#{host}#{url}"
  end
end
