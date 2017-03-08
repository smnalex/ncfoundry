module CFoundry
  module ProxyOptions
    def proxy_options_for(uri)
      proxy_uri = uri.find_proxy

      if proxy_uri.nil?
        []
      else
        proxy_user, proxy_password = proxy_uri.userinfo.split(/:/) if proxy_uri.userinfo
        [proxy_uri.host, proxy_uri.port, proxy_user, proxy_password]
      end
    end
  end
end
