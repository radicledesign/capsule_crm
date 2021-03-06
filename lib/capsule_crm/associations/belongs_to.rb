module CapsuleCRM
  module Associations
    module BelongsTo
      extend ActiveSupport::Concern

      module ClassMethods

        # Public: Add getter and setter methods for belongs to associations
        #
        # association_name  - The String name of the association
        # options           - The Hash of additional options (default: {}):
        #                     class_name: The String name of the associated
        #                     class
        #
        # Examples
        #
        # class CapsuleCRM::Person
        #   include CapsuleCRM::Associations::BelongsTo
        #
        #   belongs_to :organisation, class_name: 'CapsuleCRM::Organization'
        # end
        #
        # organisation = CapsuleCRM::Organisation.find(1)
        #
        # person = CapsuleCRM::Person.new(organisation = organisation)
        # person.organisation_id
        # => 1
        #
        # person.organisation
        # => organisation
        def belongs_to(association_name, options = {})
          foreign_key = options[:foreign_key] || :"#{association_name}_id"

          class_eval do
            attribute foreign_key, Integer
          end

          (class << self; self; end).instance_eval do
            define_method "_for_#{association_name}" do |id|
              raise NotImplementedError.new("_for_#{association_name} needs to be implemented")
            end
          end

          define_method association_name do
            instance_variable_get(:"@#{association_name}") ||
              if self.send(foreign_key)
                options[:class_name].constantize.
                find(self.send(foreign_key)).tap do |object|
                  self.send("#{association_name}=", object)
                end
              else
                nil
              end
          end

          define_method "#{association_name}=" do |associated_object|
            instance_variable_set(:"@#{association_name}", associated_object)
            id = associated_object ? associated_object.id : nil
            self.send "#{foreign_key}=", id
          end
        end
      end
    end
  end
end
