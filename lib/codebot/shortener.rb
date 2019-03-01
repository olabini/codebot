module Codebot
  module Shortener
    class Github
      # Shortens a URL with GitHub's git.io URL shortener. The domain must belong
      # to GitHub.
      #
      # @param url [String] the long URL
      # @return [String] the shortened URL, or the original URL if an error
      #                  occurred.
      def shorten_url(url)
        return url if url.to_s.empty?

        uri = URI('https://git.io')
        res = Net::HTTP.post_form uri, 'url' => url.to_s
        res['location'] || url.to_s
      rescue StandardError
        url.to_s
      end
    end

    class Custom
      def initialize(shortener_url, shortener_secret)
        @shortener_url = URI(shortener_url)
        @shortener_secret = shortener_secret
      end

      def shorten_url(url)
        return url if url.to_s.empty?

        res = Net::HTTP.post_form @shortener_url, 'url' => url.to_s, 'secret' => @shortener_secret
        res.body.strip || url.to_s
      rescue StandardError
        url.to_s
      end
    end
  end
end
