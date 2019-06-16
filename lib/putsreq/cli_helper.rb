module PutsReq
  class CLIHelper
    attr_reader :token, :to, :local

    def initialize(token, to, local)
      @token = token
      @to = to
      @local = local
    end

    def subscribe_and_forward
      puts "Listening requests from #{token}"
      puts "Forwarding to #{to}"
      puts 'Press CTRL+c to terminate'

      last_request_id = find_last_request_id

      loop do
        url = "#{base_url}#{token}/requests.json?last_request_id=#{last_request_id}"

        response = get(url)

        unless response.ok?
          puts "Could not retrieve Bucket #{token}"
          break
        end

        parsed_response = response.parsed_response

        parsed_response.each do |request|
          forward_request(request)
          last_request_id = request.dig('_id', '$oid')
        end

        timeout = parsed_response.none? ? 5 : 2.5

        sleep timeout
      end
    end

    def find_and_forward(id)
      if request = find_request(id)
        forward_request(request)
      else
        puts "Request #{id} not found"
      end
    end

    class << self
      def parse_token(token)
        if token.start_with? 'http'
          # from http://putsreq.com/token or http://putsreq.com/token/inspect
          # to token
          uri = URI(token)
          return uri.path.split('/')[1]
        end

        token
      end

      def valid_to?(to)
        url = URI.parse(to) rescue nil
        url&.kind_of?(URI::HTTP) || url&.kind_of?(URI::HTTPS)
      end
    end

    private

    def find_request(id)
      url = "#{base_url}#{token}/requests/#{id}.json"
      response = get(url)
      response.parsed_response if response.ok?
    end

    def forward_request(request)
      options = { headers:  request['headers'] }
      options[:body] = request['body'] unless request['body'].to_s.empty?

      forward_request = HTTParty.send(
        request['request_method'].downcase.to_sym,
        to,
        options
      )

      puts [
        Time.now,
        request['request_method'],
        forward_request.code
      ].join("\t")
    end

    def base_url
      local ? 'http://localhost:3000/' : 'https://putsreq.com/'
    end

    def get(url, timeout = 5)
      response = HTTParty.get(url)
      if response.code == 429
        puts 'Too Many Requests... Retrying soon'
        timeout = [30, timeout + 5].min
        sleep timeout
        return get(url, timeout)
      end

      response
    end

    def find_last_request_id
      url = "#{base_url}#{token}/last.json"
      response = get(url)
      response.parsed_response.dig('_id', '$oid') if response.ok?
    end
  end
end