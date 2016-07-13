module CFoundry
  class AuthToken
    class << self
      def from_uaa_token_info(token_info)
        new(
          token_info.auth_header,
          token_info.info[:refresh_token]
        )
      end

      def from_hash(hash)
        new(
          hash[:token],
          hash[:refresh_token]
        )
      end
    end

    def initialize(auth_header, refresh_token = nil)
      @auth_header = auth_header
      @refresh_token = refresh_token
    end

    attr_accessor :auth_header
    attr_reader :refresh_token

    def to_hash
      {
        :token => auth_header,
        :refresh_token => @refresh_token
      }
    end

    JSON_HASH = /\{.*?\}/.freeze

    # TODO: rename to #data
    def token_data
      return @token_data if @token_data
      return {} unless @auth_header

      data_json = @auth_header.split(" ", 2).last
      return {} unless data_json

      @token_data = JWT.decode(data_json, nil, false)[0].symbolize_keys
    rescue
      {}
    end

    def auth_header=(auth_header)
      @token_data = nil
      @auth_header = auth_header
    end

    def expiration
      token_data[:exp].nil? ? Time.at(0) : Time.at(token_data[:exp])
    end

    def expires_soon?
      (expiration.to_i - Time.now.to_i) < 60
    end
  end
end
