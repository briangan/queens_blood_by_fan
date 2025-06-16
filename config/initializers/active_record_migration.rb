##
# Helper methods during DB migrations to checks and avoid conflicts.
module ActiveRecord
  class Migration
    def add_column_unless_exists(table_name, column_name, type, **options)
      add_column(table_name, column_name, type, **options) unless normalized_columns(table_name).include?(column_name.to_s.downcase)
    end

    def remove_column_if_exists(table_name, *column_names)
      matched_cols = normalized_columns(table_name) & column_names.collect{|c| c.to_s.downcase }
      remove_column(table_name, *matched_cols) if matched_cols.present?
    end
    alias_method :remove_columns_if_exists, :remove_column_if_exists

    def create_table_unless_exists(table_name, **options, &block)
      create_table(table_name, **options, &block) unless table_exists?(table_name)
    end

    def drop_table_if_exists(table_name)
      drop_table(table_name, if_exists: true) # if table_exists?(table_name)
    end

    def remove_index_if_exists(table_name, columns)
      remove_index(table_name, columns) if index_exists?(table_name, columns)
    end

    def add_index_unless_exists(table_name, columns, **options)
      add_index(table_name, columns, **options) unless index_exists?(table_name, columns)
    end

    def column_exists?(table_name, column_name)
      normalized_columns(table_name).include?(column_name.to_s.downcase)
    end

    # column names lower-cased as <String>
    def normalized_columns(table_name)
      columns(table_name).collect{|c| c.name.downcase }
    end
  end
end