require 'payment_data/data'

# :KLUDGE:    Imenem    22.08.2013
#
# Prevent error "Uninitialized constant PaymentTransaction" in Payment
module PaynetEasy::PaynetEasyApi::PaymentData
  class PaymentTransaction < Data
  end
end

require 'payment_data/payment'
require 'payment_data/query_config'

module PaynetEasy::PaynetEasyApi::PaymentData
  class PaymentTransaction < Data
    # Payment transaction processed by payment query
    PROCESSOR_QUERY       = 'query'

    # Payment transaction processed by PaynetEasy callback
    PROCESSOR_CALLBACK    = 'callback'

    # Payment transaction is new
    STATUS_NEW        = 'new'

    # Payment transaction is now processing
    STATUS_PROCESSING = 'processing'

    # Payment transaction approved
    STATUS_APPROVED   = 'approved'

    # Payment transaction declined by bank
    STATUS_DECLINED   = 'declined'

    # Payment transaction declined by PaynetEasy filters
    STATUS_FILTERED   = 'filtered'

    #Payment transaction processed with error
    STATUS_ERROR      = 'error'

    # All allowed callback types
    @@allowed_processor_types =
    [
      PROCESSOR_QUERY,
      PROCESSOR_CALLBACK
    ]

    # All allowed payment transaction statuses
    @@allowed_statuses =
    [
      STATUS_NEW,
      STATUS_PROCESSING,
      STATUS_APPROVED,
      STATUS_DECLINED,
      STATUS_FILTERED,
      STATUS_ERROR
    ]

    # Payment transaction processor type
    #
    # @var  [String]
    attr_accessor :processor_type

    # Payment transaction processor name
    #
    # @var  [String]
    attr_accessor :processor_name

    # Payment transaction status
    #
    # @var  [String]
    attr_accessor :status

    # Payment transaction payment
    #
    # @var  [PaynetEasy::PaynetEasyApi::PaymentData::Payment]
    attr_accessor :payment

    # Payment transaction query config
    #
    # @var  [PaynetEasy::PaynetEasyApi::PaymentData::QueryConfig]
    attr_accessor :query_config

    # Payment transaction processing errors
    #
    # @var  [Array]
    attr_accessor :errors

    def processor_type=(processor_type)
      unless @@allowed_processor_types.include? processor_type
        raise ArgumentError, "Unknown transaction processor type given: '#{processor_type}'"
      end

      if @processor_type
        raise RuntimeError, 'You can set payment transaction processor type only once'
      end

      @processor_type = processor_type
    end

    def processor_name=(processor_name)
      if @processor_name
        raise RuntimeError, 'You can set payment transaction processor name only once'
      end

      @processor_name = processor_name
    end

    def status=(status)
      unless @@allowed_statuses.include? status
        raise ArgumentError, "Unknown transaction status given: '#{status}'"
      end

      @status = status
    end

    def status
      @status ||= STATUS_NEW
    end

    # True, if payment transaction is new
    def new?
      status == STATUS_NEW
    end

    # True, if payment transaction is now processing
    def processing?
      status == STATUS_PROCESSING
    end

    # True, if payment transaction approved
    def approved?
      status == STATUS_APPROVED
    end

    # True, if payment transaction declined or filtered
    def declined?
      [STATUS_DECLINED, STATUS_FILTERED].include? status
    end

    # True, if error occurred when processing payment transaction by PaynetEasy gateway
    def error?
      status == STATUS_ERROR
    end

    # True, if payment transaction processing is finished
    def finished?
      !new? && !processing?
    end

    def payment=(payment)
      @payment = payment

      unless @payment.has_payment_transaction? self
        @payment.add_payment_transaction self
      end
    end

    def payment
      @payment ||= Payment.new
    end

    def query_config=(query_config)
      @query_config = query_config
    end

    def query_config
      @query_config ||= QueryConfig.new
    end

    def errors
      @errors ||= []
    end

    def add_error(error)
      unless errors.include? error
        errors << error
      end
    end

    def has_errors?
      errors.any?
    end

    def last_error
      errors.last if has_errors?
    end
  end
end
