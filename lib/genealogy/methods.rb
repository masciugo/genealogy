module Genealogy
  module Methods
    extend ActiveSupport::Concern

    def foo
      'InstanceMethods#foo'
    end
    
    # link parents methods
    [:father, :mother].each do |parent|

      # no-bang version
      define_method "add_#{parent}" do |arg|
        if arg.is_a? Hash
          send("build_#{parent}",arg)
        elsif arg.is_a? self.class
          send("#{parent}=",arg)
        end
      end

      # bang version
      define_method "add_#{parent}!" do |arg|
        send("add_#{parent}",arg)
        save!
      end

    end

    # grandparents
    translation = { :father => :paternal, :mother => :maternal }
    [:father, :mother].each do |parent|
      [:father, :mother].each do |grandparent|

        # query methods

        define_method "#{translation[parent]}_grand#{grandparent}" do
          raise TooLongJumpException, "#{self} doesn't have #{parent}" unless send(parent)
          send(parent).send(grandparent)
        end

        # link methods
        
        # no-bang version
        define_method "add_#{translation[parent]}_grand#{grandparent}" do |arg|
          raise TooLongJumpException, "#{self} doesn't have #{parent}" unless send(parent)
          if arg.is_a? Hash
            send(parent).send("build_#{grandparent}",arg)
          elsif arg.is_a? self.class
            send(parent).send("#{grandparent}=",arg)
          end
        end

        # bang version
        define_method "add_#{translation[parent]}_grand#{grandparent}!" do |arg|
          raise TooLongJumpException, "#{self} doesn't have #{parent}" unless send(parent)
          send(parent).send("add_#{grandparent}",arg)
          send(parent).save!
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