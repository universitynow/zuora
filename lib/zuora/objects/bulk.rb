module Zuora::Objects
  #class to do bulk operations in Zuora		
  class Bulk
  	attr_accessor :objects, :operation, :ons, :zns, :remote_name

  	def setup(input)
  		self.objects = Array.new
  		self.objects = input
  		self.ons = namespace('http://object.api.zuora.com/')
  		self.zns = namespace('http://api.zuora.com/')
  		self.remote_name = self.objects[0].remote_name
  	end
  	#do the operation in bulk
  	#take the objects and break them up into groups of 50
    def create
      result = Zuora::Api.instance.request :create, generate_xml
      #parse the result. i.e set the id if it success was true
      #what to do if it fails?
      result[:create_response][:result].each_with_index do |res, index|
          if res[:success] == true
            objects[index].id = res[:id]
          end
      end
    end
    #generate the xml for the call
    def generate_xml
    	xml = Builder::XmlMarkup.new
      objects.each do |o|
        generate_object xml, o
      end
      xml.xml     		
    end
    #generate xml for an object
    def generate_object(builder, object)
    	builder.__send__(self.zns, :zObjects, 'xsi:type' => "ins1:#{self.remote_name}") do |a|
    		object.to_hash.each do |k,v|
	        a.__send__(self.ons, k.to_s.zuora_camelize.to_sym, v) unless v.nil?
	      end
    	end
    end

    def namespace(uri)
      #Zuora::Api.instance.client.soap.namespace_by_uri(uri)
    end

  end
end