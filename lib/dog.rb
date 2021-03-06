require 'pry'

class Dog 
  
  attr_accessor :id, :name, :breed
  
  def initialize(id: nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed
  end
  
  def self.create_table 
    sql = <<-SQL
      CREATE TABLE dogs (
      id INTEGER PRIMARY KEY, 
      name TEXT, 
      breed TEXT
      )
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs 
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def save 
    sql = <<-SQL
      INSERT INTO dogs
      (name, breed)
      VALUES (
      ?,?
      )
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  
  def self.new_from_db(row)
    dog = self.new(name: row[1], breed: row[2])
    dog.id = row[0]
    dog.name = row[1]
    dog.breed = row[2]
    dog
  end
  
  def self.find_by_name(name) 
    sql = <<-SQL
      SELECT *
      FROM dogs 
      WHERE name = ?
      SQL
      
      row =DB[:conn].execute(sql, name)[0]
      new_from_db(row)
  end
  
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end
  
  def update 
    sql = <<-SQL
    UPDATE dogs 
    SET name = ?, breed = ? 
    WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * 
    FROM dogs
    WHERE id = ?
    SQL
    
    row = DB[:conn].execute(sql, id)[0]
    new_from_db(row)
  end
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
      
    end
    dog
  end
  
end