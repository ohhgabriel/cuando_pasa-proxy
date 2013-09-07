require 'mongo'

module CuandoPasa::Proxy
  # The database is a service, so it's must be started with start before it can
  # can be used, and stopped with stop when is no longer needed. In the mid
  # time it can be obtained with get.
  #
  # Right now the only database supported is MongoDB whose client it's adapted
  # in the Mongo class to provide an interface that is adequate for this
  # library and MongoDB agnostic at the same time.
  class DB
    # Starts the database service, before the database can be used.
    def self.start(uri)
      # NOTE: If more databases are added, inspect the URI protocol to obtain
      # the right adapter, and keep a reference so stop can access it.
      Mongo.connect(uri)
    end

    # Stops the database service, after the database is no longer needed.
    def self.stop
      Mongo.close
      @db = nil
    end

    # Gets the database, which is an object whose interface is not tied to any
    # implementation. Since MongoDB is the only implementation supported, see
    # Mongo for the API details.
    def self.get
      @db ||= Mongo.new
    end

    # Adapter for MongoDB.
    class Mongo
      @@client = nil

      # Conects to MongoDB. We only need to do this once because the MongoDB
      # client already has a connection pool.
      def self.connect(uri)
        raise "already connected" unless @@client.nil?
        @@client = ::Mongo::MongoClient.from_uri(uri)
      end

      # Closes the connection to MongoDB.
      def self.close
        @@client.close
      end

      def initialize
        @db = @@client.db
      end

      # Adds a given document to a given collection.
      def insert(coll, doc)
        @db[coll].insert(doc)
      end

      # Returns a document from a given collection, whose value for a given
      # field is the maximum of the collection.
      def max(coll, field)
        @db[coll].find.sort(field => -1).limit(1).first
      end

      # Returns all the documents from a given collection.
      def all(coll)
        @db[coll].find
      end

      # Drops the given collection.
      def drop(coll)
        @db[coll].drop
      end
    end
  end
end
