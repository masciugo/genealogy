module Genealogy
  module Methods
    extend ActiveSupport::Concern

    def foo
      'InstanceMethods#foo'
    end

    [:father, :mother].each do |parent|
      define_method "add_#{parent}" do |arg|
        if arg.is_a? Hash
          send("build_#{parent}",arg)
        elsif arg.is_a? self.class
          send("parent=",arg)
        end
      end
    end

    module ClassMethods
      def foo
        'ClassMethods#foo'
      end
    end

  end
end