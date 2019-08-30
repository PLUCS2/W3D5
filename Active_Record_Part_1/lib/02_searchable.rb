require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
   col = params.keys.map {|k| "#{k} = ?"}
   cols = col.join(" AND ")
   vals = params.values
    puts cols 
    puts vals
  rows = DBConnection.execute(<<-SQL, *vals)
    SELECT 
      * 
    FROM  
      #{self.table_name}
    WHERE 
      #{cols}
  SQL
    
  rows.map {|row| self.new(row)}
end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
