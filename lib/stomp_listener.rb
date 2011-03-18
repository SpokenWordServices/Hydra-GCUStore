require 'rubygems'
require 'stomp'


class StompListener
  require 'singleton'
  include Singleton

  def initialize(params={})
    @port = 61613
    @host = "localhost"
    @user = "fedoraStomper"
    @password = "fedoraStomper"
    @reliable = true
    @clientid = "fedora_stomper"
    @destination = "/topic/fedora.apim.update"
  end

  def listen
    begin
        $stderr.print "Connecting to stomp://#{@host}:#{@port} as #{@user}\n"
        @conn = Stomp::Connection.open(@user, @password, @host, @port, @reliable, 5, {"client-id" => @clientid} )
        $stderr.print "Getting output from #{@destination}\n"

        @conn.subscribe(@destination, {"activemq.subscriptionName" => @clientid, :ack =>"client" })
        while true
            @msg = @conn.receive
            pid = @msg.headers["pid"]
            method = @msg.headers["methodName"]

            puts @msg.headers.inspect
            puts "\nPID: #{@msg.headers["pid"]}\n"
            unless method == "purgeObject"
              solrizer = Solrizer::Fedora::Solrizer.new
              solrizer.solrize @msg.headers["pid"]
            else
              ActiveFedora::SolrService.instance.conn.delete(pid)
            end
            puts  "updated solr index for #{@msg.headers["pid"]}\n"
            @conn.ack @msg.headers["message-id"]
        end
        @conn.join

    rescue Exception => e
     p e
    end
  end

  def stop
    @conn.close if @conn
  end

end
