require 'sinatra'
require 'json'
require 'faraday'
require 'openssl'
require 'base64'

$stdout.sync = true

# Use one of the following depending on the platform that is sending
#   the webhook:
# https://api.travis-ci.org
# https://api.travis-ci.com
DEFAULT_API_HOST = 'https://api.travis-ci.org'
API_HOST = ENV.fetch('API_HOST', DEFAULT_API_HOST)
SKIP_VERIFY = ENV.fetch('SKIP_VERIFY', false)
GITHUB_TOKEN = ENV.fetch('GITHUB_TOKEN')

def repo_slug
  env['HTTP_TRAVIS_REPO_SLUG']
end

post '/' do

  json_payload = params.fetch('payload', '')
  signature    = request.env["HTTP_SIGNATURE"]

  if verify(json_payload, signature)
    status 200
    payload = JSON.parse(json_payload)
    conn = Faraday.new('https://api.github.com/') do |c|
        c.adapter Faraday.default_adapter
    end
    meta = JSON.parse(payload["message"])
    repo_slug = meta["repo_slug"]
    commit_hash = meta["commit"]
    conn.authorization :token, GITHUB_TOKEN
    response = conn.post do |req|
        req.url "/repos/#{repo_slug}/statuses/#{commit_hash}"
        req.headers['Content-Type'] = 'application/json'
        req.body = JSON.dump({
            state: state_travis2github(payload["status_message"]),
            target_url: payload["build_url"],
            description: "Downstream Travis",
            context: "continuous-integration/downstream-travis"})
    end
    response.body
  else
    status 400
    "verification failed\n"
  end

end

# Travis: Pending, Passed, Fixed, Broken, Failed, Still Failing
# GitHub: pending, success, error, failure
def state_travis2github(st)
  case st
  when "Pending"       then "pending"
  when "Passed"        then "success"
  when "Fixed"         then "success"
  when "Broken"        then "failure"
  when "Failed"        then "failure"
  when "Still Failing" then "failure"
  else                      "error"
  end
end

def verify(json_payload, signature)
  return true if SKIP_VERIFY
  return false if not signature
  pkey = OpenSSL::PKey::RSA.new(public_key)
  pkey.verify(
      OpenSSL::Digest::SHA1.new,
      Base64.decode64(signature),
      json_payload
    )
end

def public_key
  conn = Faraday.new(:url => API_HOST) do |c|
    c.adapter Faraday.default_adapter
  end
  response = conn.get '/config'
  JSON.parse(response.body)["config"]["notifications"]["webhook"]["public_key"]
end
