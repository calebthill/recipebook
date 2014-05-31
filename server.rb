require 'sinatra'
require 'pry'
require 'pg'

########## METHODS ##############

def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')
    yield(connection)
    ensure
    connection.close
  end
end
#################################

get '/recipes' do
  if params[:search]
     query = "SELECT recipes.name, recipes.id FROM recipes
              WHERE recipes.name ILIKE '%#{params[:search]}%'
              ORDER BY recipes.name;"
   else
    query = "SELECT recipes.name, recipes.id FROM recipes ORDER BY recipes.name"
  end
  recipes = db_connection do |conn|
    conn.exec(query)
  end
  @recipes = recipes.to_a
  erb :recipes
end

get '/recipes/:id' do
  id = params[:id]
  recipes = db_connection do |conn|
    query = "SELECT recipes.name AS name, recipes.instructions AS instructions, recipes.description AS description, ingredients.name AS ingredients, ingredients.recipe_id FROM recipes
            JOIN ingredients ON ingredients.recipe_id = recipes.id WHERE ingredients.recipe_id = '#{params[:id]}';"
    conn.exec(query)
  end
  @recipes1 = recipes.to_a
  erb :show
end
