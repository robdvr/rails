require 'set'

module ActiveRecord
  # :stopdoc:
  module ConnectionAdapters
    # An abstract definition of a column in a table.
    class Column
      TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'on', 'ON'].to_set
      FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF'].to_set

      module Format
        ISO_DATE = /\A(\d{4})-(\d\d)-(\d\d)\z/
        ISO_DATETIME = /\A(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)(\.\d+)?\z/
      end

      attr_reader :name, :default, :cast_type, :null, :sql_type, :default_function

      delegate :type, :precision, :scale, :limit, :klass, :accessor,
        :text?, :number?, :binary?, :serialized?, :changed?,
        :type_cast, :type_cast_for_write, :type_cast_for_database,
        :type_cast_for_schema,
        to: :cast_type

      # Instantiates a new column in the table.
      #
      # +name+ is the column's name, such as <tt>supplier_id</tt> in <tt>supplier_id int(11)</tt>.
      # +default+ is the type-casted default value, such as +new+ in <tt>sales_stage varchar(20) default 'new'</tt>.
      # +cast_type+ is the object used for type casting and type information.
      # +sql_type+ is used to extract the column's length, if necessary. For example +60+ in
      # <tt>company_name varchar(60)</tt>.
      # It will be mapped to one of the standard Rails SQL types in the <tt>type</tt> attribute.
      # +null+ determines if this column allows +NULL+ values.
      def initialize(name, default, cast_type, sql_type = nil, null = true)
        @name             = name
        @cast_type        = cast_type
        @sql_type         = sql_type
        @null             = null
        @default          = extract_default(default)
        @default_function = nil
      end

      def has_default?
        !default.nil?
      end

      # Returns the human name of the column name.
      #
      # ===== Examples
      #  Column.new('sales_stage', ...).human_name # => 'Sales stage'
      def human_name
        Base.human_attribute_name(@name)
      end

      def extract_default(default)
        type_cast_for_write(type_cast(default))
      end
    end
  end
  # :startdoc:
end
