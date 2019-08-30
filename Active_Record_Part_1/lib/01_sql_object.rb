require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    # ...
    if @columns == nil 
      cats = self.table_name
      limits = 0 
      # debugger
      a = DBConnection.execute2(<<-SQL, limits)
        SELECT 
          * 
        FROM
          #{self.table_name}
        LIMIT 
          ?
      SQL
      # debugger
      @columns = a.first.map {|ele| ele.to_sym } 
    else 
      @columns
    end 
  end

  def self.finalize!
    columns.each do |col|
      define_method("#{col}") do 
        self.attributes[col]
      end   

      define_method("#{col}=") do |add|
        self.attributes[col] = add
      end 
    end  
  end

  def self.table_name=(table_name)
    table_name = table_name
  end

  def self.table_name
    "#{self}s".downcase
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT 
      * 
    FROM 
      #{self.table_name}
    SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    results.map do |row|
      self.new(row)
    end 
  end

  def self.find(id)
    row = DBConnection.execute(<<-SQL, id) 
    SELECT 
      *
    FROM 
      #{self.table_name}
    WHERE 
      id = ? 
    SQL
    return nil if row.empty? 
    self.new(row.first)
  end

  def initialize(params = {})
    params.each_pair do |key, val| 
      k = key
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k.to_sym)
      send("#{k}=", val)
    end 
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map {|col| send("#{col}")}
  end

  def insert
    col_names = self.class.columns.join(", ")
    question_marks = (["?"] * self.class.columns.length).join(", ")
    info = attribute_values
    DBConnection.execute(<<-SQL, *info)
    INSERT INTO 
      #{self.class.table_name} (#{col_names})
    VALUES 
      (#{question_marks})
    SQL

    self.id= self.class.all.last.id

  end

  def update
    col_names = self.class.columns.map {|col| "#{col} = ?"}
    col_name = col_names.join(", ")
    info = attribute_values
    DBConnection.execute(<<-SQL, *info)
    UPDATE 
      #{self.class.table_name}
    SET 
      #{col_name}
    WHERE 
      id = #{self.id}
    SQL
  end

  def save
    if self.id == nil 
      self.insert
    else 
      self.update
    end 
  end
end
