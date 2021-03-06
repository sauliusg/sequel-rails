require "generators/sequel"

module Sequel
  class IllegalMigrationNameError < StandardError
    def initialize(name)
      super("Illegal name for migration file: #{name}\n\t(only lower case letters, numbers, and '_' allowed)")
    end
  end

  module Generators
    class MigrationGenerator < Base #:nodoc:

      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      def create_migration_file
        set_local_assigns!
        validate_file_name!
        migration_template "migration.rb.erb", "db/migrate/#{file_name}.rb"
      end

      attr_reader :migration_action, :table_action, :column_action, :use_change

      protected

      def set_local_assigns!
        if file_name =~ /^(add|drop|remove)_.*_(?:to|from)_(.*)/
          @table_action   = 'alter'
          @table_name     = $2.pluralize
          @column_action  = $1 == 'add' ? 'add' : 'drop'
          @use_change     = @column_action == 'add' ? true : false
        elsif file_name =~ /^(create|drop)_(.*)$/
          @table_action   = $1
          @table_name     = $2.pluralize
          @column_action  = 'add'
          @use_change     = @table_action == 'create' ? true : false
        else
          @table_action   = 'alter'
          if file_name =~ /^(alter)_(.*)/
            @table_name   = $2.pluralize
          else
            @table_name   = file_name.pluralize
          end
          @use_change     = false
          @column_action  = 'add'
        end
      end

      def validate_file_name!
        unless file_name =~ /^[_a-z0-9]+$/
          raise IllegalMigrationNameError.new(file_name)
        end
      end
    end
  end
end
