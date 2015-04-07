module POSConnector
  module QBIntegration
    class Order < Base
      attr_accessor :order

      def initialize(message = {}, config)
        super
        @order = payload[:order]
      end

      def create_directly
        sales_receipt = sales_receipt_service.create
        text = "Created Quickbooks Sales Receipt #{sales_receipt.id} for order #{sales_receipt.doc_number}"
        [200, text]
      end

      def create
        if sales_receipt = sales_receipt_service.find_by_order_number
          raise AlreadyPersistedOrderException.new(
            "Order #{order['number']} already has a sales receipt with id: #{sales_receipt.id}"
          )
        end

        create_directly
      end

      def update_directly(sales_receipt)
        sales_receipt = sales_receipt_service.update sales_receipt
        [200, "Updated Quickbooks Sales Receipt #{sales_receipt.doc_number}"]
      end

      def update
        unless sales_receipt = sales_receipt_service.find_by_order_number
          raise RecordNotFound.new "Quickbooks Sales Receipt not found for order #{order['number']}"
        end

        update_directly(sales_receipt)
      end

      def create_or_update
        if sales_receipt = sales_receipt_service.find_by_order_number
          update_directly(sales_receipt)
        else
          create_directly
        end
      end

      def cancel
        unless sales_receipt = sales_receipt_service.find_by_order_number
          raise RecordNotFound.new "Quickbooks Sales Receipt not found for order #{order['number']}"
        end

        credit_memo = credit_memo_service.create_from_receipt sales_receipt
        text = "Created Quickbooks Credit Memo #{credit_memo.id} for canceled order #{sales_receipt.doc_number}"
        [200, text]
      end
    end
  end
end
