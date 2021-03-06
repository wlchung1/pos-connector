module POSConnector
  module QBIntegration
    module Helper
      def lookup_value!(hash, key, ignore_case = false, default = nil)
        hash = Hash[hash.map{|k,v| [k.downcase,v]}] if ignore_case

        if default
          value = hash.fetch(key, default)
        else
          value = hash[key]
        end

        value || (raise LookupValueNotFoundException.new("Can't find the key '#{key}' in the provided mapping"))
      end

      def self.payment_method_names service
        fetch_names_hash service
      end

      def self.customer_names service
        fetch_names_hash service
      end

      private
      def self.fetch_names_hash service
        data = {}
        page = 1
        per_page = 20
        list = service.list([],page,per_page)
        while(list.count != 0) do
          list.entries.each do |entry|
            data[entry.id.value] = entry.name
          end
          page += 1
          list = service.list([],page,per_page)
        end
        data
      end
    end
  end
end
