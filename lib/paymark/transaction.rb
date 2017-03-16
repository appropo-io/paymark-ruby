module Paymark

  class TransactionResult < Object
    attr_accessor :status
    attr_accessor :message
    attr_accessor :transaction

    def value_map(key, value)
      if key == 'Transaction'
        value ? Transaction.new(value) : nil
      else
        super
      end
    end
  end

  class CreditCardTransaction < Object
#     AccountId"=>"621495",
    attr_accessor :account_id
# 11:21:00 web.1       |    "AcquirerResponseCode"=>"00",
    attr_accessor :acquirer_response_code
# 11:21:00 web.1       |    "Amount"=>"18.90",
    attr_accessor :amount
# 11:21:00 web.1       |    "AuthCode"=>"332212",
    attr_accessor :auth_code
# 11:21:00 web.1       |    "BatchNumber"=>"20161007",
    attr_accessor :batch_number
# 11:21:00 web.1       |    "CardExpiry"=>"1119",
    attr_accessor :card_expiry
# 11:21:00 web.1       |    "CardHolder"=>"Test",
    attr_accessor :card_holder
# 11:21:00 web.1       |    "CardNumber"=>"411111******1111",
    attr_accessor :card_number
# 11:21:00 web.1       |    "CardStored"=>"false",
    attr_accessor :card_stored
# 11:21:00 web.1       |    "CardToken"=>nil,
    attr_accessor :card_token
# 11:21:00 web.1       |    "CardType"=>"VISA",
    attr_accessor :card_type
# 11:21:00 web.1       |    "ErrorCode"=>nil,
    attr_accessor :error_code
# 11:21:00 web.1       |    "ErrorMessage"=>nil,
    attr_accessor :error_message
# 11:21:00 web.1       |    "Particular"=>"Longboard Burrito and Lil' Burrito",
    attr_accessor :particular
# 11:21:00 web.1       |    "ReceiptNumber"=>"26187798",
    attr_accessor :receipt_number
# 11:21:00 web.1       |    "Reference"=>"49429",
    attr_accessor :reference
# 11:21:00 web.1       |    "Status"=>"SUCCESSFUL",
    attr_accessor :status
# 11:21:00 web.1       |    "TransactionDate"=>"2016-10-07T09:34:45",
    attr_accessor :transaction_date
# 11:21:00 web.1       |    "TransactionId"=>"P161010001106906",
    attr_accessor :transaction_id
# 11:21:00 web.1       |    "Type"=>"PURCHASE"
    attr_accessor :type
  end

  class Transaction < Object
    # TransactionId String Paymark assigned unique transaction identifier
    attr_accessor :transaction_id
    # Type String
    # Transaction type (PURCHASE, AUTHORISATION, REFUND,
    # CAPTURE)
    attr_accessor :type
    # AccountID Integer Paymark Account ID used for the transaction
    attr_accessor :account_id
    # Status String
    # Status of the transaction (UNKNOWN, SUCCESSFUL,
    # DECLINED, BLOCKED, FAILED, INPROGRESS)
    attr_accessor :status
    # TransactionDate DateTime Date and time when the transaction is processed
    attr_accessor :transaction_date
    # BatchNumber String
    # Content of this data can vary based on type of transaction.
    # Currently when contains a value, it is a string representing the
    # “estimated settlement date” of the transaction.
    attr_accessor :batch_number

    # ReceiptNumber Integer Unique identifier for the receipt of the transaction
    attr_accessor :receipt_number
    # AuthCode String Code assigned by the payment switch
    attr_accessor :auth_code
    # Amount Decimal The amount the transaction in NZD
    attr_accessor :amount
    # Reference String Reference used for the transaction – defined by the merchant
    attr_accessor :reference
    # Particular String Particular used for the transaction – defined by the merchant
    attr_accessor :particular
    # CardType String
    # The credit card type used for this transaction. (MASTERCARD,
    # VISA, AMERICAN_EXPRESS, DINERS_CLUB, QCARD)
    attr_accessor :card_type

    # CardNumber String Masked card number showing first 6 and last 4 digits
    attr_accessor :card_number
    # CardExpiry String Expiry date of the credit card in numeric format “MMYY”
    attr_accessor :card_expiry
    # CardHolder String The cardholder name initially collected from the secure page
    attr_accessor :card_holder
    # MerchantToken String
    # The Merchant Token registered with Paymark for the Card used
    # for this transaction. Only available if merchant_token was set to 1
    attr_accessor :merchant_token
    # CardStored Boolean Whether or not the card was stored 0 or 1
    attr_accessor :card_stored
    # CardToken String
    # The token of the newly stored card only available if the
    # CardStored was set to 1 and the cardholder chose to store their
    # card details.
    attr_accessor :card_token
    # TokenReference String Merchant defined reference associated with the token.
    attr_accessor :token_reference
    # ErrorCode String
    # The error code indicating the type of error that occurred. –See
    # Appendix B
    attr_accessor :error_code
    # ErrorMessage String
    # The error message explaining what the error means. –See
    # Appendix B
    attr_accessor :error_message
    # AcquirerResponseCode
    attr_accessor :acquirer_response_code
  end

end
