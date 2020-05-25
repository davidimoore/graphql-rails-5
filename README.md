# README

The graphql Gem generates all needed base objects

For this example api I created the following graphql schema:

```
type Company {
  id: ID!
  motto: String
  name: String
  postalCode: Int
  users: [User!]
  userCount: Int
}

type Query {
  companies: [Company!]!
}

type User {
  email: String
  company: Company!
}
```

And the following database schema:

```ruby
    create_table "companies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "postal_code"
    end
  
    create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
      t.string "email"
      t.bigint "company_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["company_id"], name: "index_users_on_company_id"
    end
```

* Root Types - The schema is composed of 3 types. 
  * Query
    * A query is composed of fields. The first field is the Root Field `query`. This is the entry
    point for querying the GraphQL schema. The company field is an object defined by `CompanyType`
    that is composed of two scalar fields `name` (string) and  `postalCode` (integer).
    
        ``` 
          query {
            company {
              name
              postalCode
            }
          }
        ```

    * For each field defined for a `Type` there needs to be a corresponding resolver method. This 
    method would be the same name as the field. For the example above you would normally define an
    instance method `#name` and `postal_code` for the `CompanyType`. 
    
        ```ruby
           module Types
             class CompanyType < Types::BaseObject
               field :name, String, null: true
               field :postal_code, Integer, null: true
        
               def name 
                 #...
               end
        
               def postal_code 
                 #...
               end    
             end
          end
        ```
      
    However, because of the name
    of `Company` and `CompanyType`, the fields `name` and `postalCode` don't require resolver methods
    because resolver methods are dynamically created using the database column definition.  
        
       ```ruby
           module Types
             class CompanyType < Types::BaseObject
               field :name, String, null: true
               field :postal_code, Integer, null: true
             end
           end
       ```    
    
    You can also add resolver methods and replace the built in respose by using
    the `object` variable. The object variable is available to the instance of the
    type.
    
       ```ruby
           module Types
             class CompanyType < Types::BaseObject
               field :name, String, null: true
               field :postal_code, Integer, null: true
        
                def name 
                 "NAME: " + object.name
                end
             end
           end
       ```
    
    You can also add fields to the `CompanyType` that have no matching database
    column name. I've added the field motto:

       ```ruby
          module Types
            class CompanyType < Types::BaseObject
              field :name, String, null: true
              field :postal_code, Integer, null: true
        
               def mott 
                 object.name + " does it best!"
               end
            end
          end
       ```
    
    * N + 1 Issues
      Shopify provides the graphql-batch gem for using Promises as well as implementing the DataLoader pattern.
      The dataloader pattern prevents N + 1 queryies 
        
      There are several classes implemented from the examples section of the gem that are immediately useful:
        - RecordLoader - Implements Promises and provides the the ability to build batch 
        [queries](https://github.com/Shopify/graphql-batch#promises)
        - CountLoader - Returns a count of records.The example used in the api is for the 
        `userCount` field on the `CompanyType`
            ```
            module Types
              class CompanyType < Types::BaseObject
                #...
                field :user_count, Integer, null: false
            
                def user_count
                  CountLoader.for(model: Company, association_name: :users).load(object.id)
                end
              end
            end
            ```  
            
        - AssociationLoader - loads associations while avoiding N + 1 queries:

            ```
            def users
              AssociationLoader.for(model: Company, association_name: :users).load(object)
            end
            ```
      
            With the following Query
    
             ```
                    query {
                      companies {
                        id
                        motto
                      
                        users {
                          email
                        }
                      }
                    }
             ```
               
            Before using the Association Loader 
         
            ```
                Processing by GraphqlController#execute as */*
                  Parameters: {"operationName"=>nil, "variables"=>{}, "query"=>"{\n  companies {\n    id\n    motto\n    users {\n      email\n    }\n  }\n}\n", "graphql"=>{"operationName"=>nil, "variables"=>{}, "query"=>"{\n  companies {\n    id\n    motto\n    users {\n      email\n    }\n  }\n}\n"}}
                  Company Load (0.4ms)  SELECT `companies`.* FROM `companies`
                  ↳ app/controllers/graphql_controller.rb:15
                  User Load (0.3ms)  SELECT `users`.* FROM `users` WHERE `users`.`company_id` = 3
                  ↳ app/controllers/graphql_controller.rb:15
                  User Load (0.3ms)  SELECT `users`.* FROM `users` WHERE `users`.`company_id` = 4
                  ↳ app/controllers/graphql_controller.rb:15
                  User Load (0.2ms)  SELECT `users`.* FROM `users` WHERE `users`.`company_id` = 5
                  ↳ app/controllers/graphql_controller.rb:15
                  User Load (0.2ms)  SELECT `users`.* FROM `users` WHERE `users`.`company_id` = 6
                  ↳ app/controllers/graphql_controller.rb:15
                  User Load (0.2ms)  SELECT `users`.* FROM `users` WHERE `users`.`company_id` = 7
                  ↳ app/controllers/graphql_controller.rb:15
                Completed 200 OK in 45ms (Views: 0.5ms | ActiveRecord: 17.4ms)
            ```
        
          After using the Association Loader
        
          ```
            Company Load (0.3ms)  SELECT `companies`.* FROM `companies`
            ↳ app/controllers/graphql_controller.rb:15
            User Load (2.5ms)  SELECT `users`.* FROM `users` WHERE `users`.`company_id` IN (3, 4, 5, 6, 7)
          ```

