module Paymark
  class Client

    attr_accessor :url, :headers

    def initialize(options = {})
      site = options.delete(:test)
      @url = "https://#{ site.present? ? site : :secure }.paymarkclick.co.nz/api"
      @headers = options.delete(:headers) || {}
      @options = options
    end

    def client
      @conn ||= Faraday.new(:url => @url) do |faraday|
        faraday.response :logger, ::Logger.new(STDOUT), bodies: (ENV["HTTP_LOG_BODIES"] == "true") unless (ENV["RACK_ENV"] == "test" || ENV["RAILS_ENV"] == "test")

        # faraday.ssl[:verify] = false
        # faraday.request :json

        faraday.response :json, :content_type => /\bjson$/
        faraday.response :xml, :content_type => /\bxml$/

        faraday.request :url_encoded
        # faraday.params_encoder = Faraday::FlatParamsEncoder
        # faraday.use :instrumentation
        faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP

        faraday.headers = @headers
        #faraday.basic_auth @options[:username], @options[:password] # faraday < 1
        faraday.request :basic_auth, @options[:username], @options[:password] # faraday 1.x
        #faraday.request :authorization, :basic, @options[:username], @options[:password] # faraday 2.x
      end
      @conn
    end

    def get_payment_url(amount_in_dollars, transaction_id, particular, args = {})

      options = @options.merge(args)

      query_params = {
        username: options[:username],
        password: options[:password],
        cmd: options[:cmd],
        account_id: options[:account_id],
        amount: amount_in_dollars,
        reference: transaction_id,
        particular: particular[0..40],
        return_url: options[:return_url],
        notification_url: options[:notification_url],
        store_card_without_input: options[:save_card] == true ? 1 : 0
      }

      response = client.post("webpayments/paymentservice/rest/WPRequest", query_params)

      if response.status == 200
        response.body['string']
      else
        body = response.body
        raise Paymark::Error, body.dig('error','errormessage') if body.is_a? Hash
        raise Paymark::Error, "#{response.status} Server Error"
      end
    end

    def get_result(result_id)
      # https://secure.paymarkclick.co.nz/api/webpayments/paymentservice/rest/QueryDirectPostResultByResultId

      query_params = {
        username: @options[:username],
        password: @options[:password],
        account_id: @options[:account_id],
        result_id: result_id,
      }
      response = client.get("webpayments/paymentservice/rest/QueryDirectPostResultByResultId", query_params)

      if response.status == 200
        TransactionResult.new(response.body['DirectPostResult'])
      elsif response.body.is_a? Hash
        raise Paymark::Error, Exception.new(response.body.dig('error','errormessage'))
      else
        raise Paymark::Error, response.body || "HTTP #{response.status}"
      end
    end

    # by reference, txn_id, particular
    def get_transaction(key_value_pair)
      query_params = {
        username: @options[:username],
        password: @options[:password],
        account_id: @options[:account_id],
      }

      key, value = key_value_pair.first
      response = case key
      when :reference
        query_params[:reference] = value
        client.get("webpayments/paymentservice/rest/QueryTransactionByReference", query_params)
      when :txn_id
        query_params[:txn_id] = value
        client.get("webpayments/paymentservice/rest/QueryTransactionByTxnId", query_params)
      when :particular
        query_params[:particular] = value[0..40]
        client.get("webpayments/paymentservice/rest/QueryTransactionByParticular", query_params)
      else
        raise Paymark::Error, "Unsupported get by: #{key}"
      end

      if response.status == 200
        CreditCardTransaction.new(response.body['CreditCardTransaction'])
      elsif response.body.is_a? Hash
        raise Paymark::Error, response.body.dig('CreditCardTransaction','error_message')
      else
        raise Paymark::Error, response.body || "HTTP #{response.status}"
      end
    end

    def purchase(card_token, amount_in_dollars, transaction_id, particular, args = {})
      options = @options.merge(args)

      query_params = {
        # username: options[:username],
        # password: options[:password],
        accountId: options[:account_id],
        amount: amount_in_dollars,
        reference: transaction_id,
        particular: particular[0..40]
      }

      response = client.post("transaction/purchase/#{card_token}", query_params)
      if response.status == 200
        CreditCardTransaction.new(response.body)
      else
        body = response.body
        raise Paymark::Error, body.dig('message') if body.is_a? Hash
        raise Paymark::Error, "#{response.status} Server Error"
        # {"code":5000,"message":"Payment Account ID is invalid"}
      end
    end

  end
end
