Hash Mapper
===========

Ruby DSL for parsing hashes.

Installation
------------

hash_mapper is hosted on gemcutter.

If you are using bundle (and you should):

    gem 'hash_mapper'

Run `bundle` and start hacking.

Usage
-----

Simple example:

    require "hash_mapper"
    hash = {
      :person => {
        :first_name => "Jonh",
        :last_name => "Doe",
        :address => {
          :street => "Hoża",
          :city => "Warsaw",
          :zip => "12345"
        }
      }
    }

    hash_converted = HashMapper.convert(hash) do
      path "person" do
        map "{first_name} {last_name}", "name"
        path "address" do
          map "{street} {city} {zip}", "address"
        end
      end
    end

    pp hash_converted

For more features, checkout tests. There are cool things like: #get, #set methods etc.

Contributing
------------

* Fork the project.
* Create branch for your changes
* Write tests
* Write change / fix
* Commit
* Pull request

Author
-------

- Łukasz Strzałkowski (<http://github.com/strzalek>)