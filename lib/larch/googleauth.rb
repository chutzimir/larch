module Larch; class GoogleAuth

  require 'singleton'
  include Singleton

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

  def initialize

    require 'googleauth'
    require 'googleauth/stores/file_token_store'

    scope       = 'https://mail.google.com/'
    client_id   = ::Google::Auth::ClientId.from_file(
      File.expand_path(File.join('~', '.larch', 'google_client_id.json'))
    )
    token_store = ::Google::Auth::Stores::FileTokenStore.new(
      :file => File.expand_path(File.join('~', '.larch','google_tokens.yaml'))
    )
    authorizer  = ::Google::Auth::UserAuthorizer.new(
      client_id, scope, token_store
    )
    user_id     = 'default'
    @credentials = authorizer.get_credentials(user_id)

    if @credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      $stderr.puts "Open #{url} in your browser and enter the resulting code:"
      code = gets
      @credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
  end

  def access_token
    if @credentials.expired? then
      @credentials.refresh!
    end
    @credentials.access_token
  end

end

end
