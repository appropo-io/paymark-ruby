module Paymark
  class Client

    attr_accessor :url, :headers

    def initialize(options = {})
      @url = "https://#{ options.delete(:test).present? ? :demo : :secure }.paymarkclick.co.nz/api/webpayments/paymentservice/rest"
      @headers = options.delete(:headers) || {}
      @options = options
    end

    def client
      @conn ||= Faraday.new(:url => @url) do |faraday|
        # faraday.response :logger, ::Logger.new(STDOUT), bodies: true

        # faraday.ssl[:verify] = false
        # faraday.request :json

        faraday.response :json, :content_type => /\bjson$/
        faraday.response :xml, :content_type => /\bxml$/

        faraday.request :url_encoded
        # faraday.params_encoder = Faraday::FlatParamsEncoder
        # faraday.use :instrumentation
        faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
      end
      @conn.headers = @headers
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
        return_url: options[:return_url]#,
        # store_card_without_input: save_card ? 1 : 0
      }

      response = client.post("WPRequest", query_params)

      if response.status == 200
        response.body['string']
      else
        raise Exception.new(response.body.dig('error','errormessage'))
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
      response = client.get("QueryDirectPostResultByResultId", query_params)

      if response.status == 200
        TransactionResult.new(response.body['DirectPostResult'])
      else
        raise Exception.new(response.body.dig('error','errormessage'))
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
      response =  case key
      when :reference
        query_params[:reference] = value
        client.get("QueryTransactionByReference", query_params)
      when :txn_id
        query_params[:txn_id] = value
        client.get("QueryTransactionByTxnId", query_params)
      when :particular
        query_params[:particular] = value[0..40]
        client.get("QueryTransactionByParticular", query_params)
      else
        raise Exception.new("Unsupported get by: #{key}")
      end

      if response.status == 200
        CreditCardTransaction.new(response.body['CreditCardTransaction'])
      else
        raise Exception.new(response.body.dig('CreditCardTransaction','error_message'))
      end
    end

  end
end
