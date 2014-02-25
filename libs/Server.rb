require 'thread'
require 'benchmark'
require 'socket'
#require 'ruby-prof'
require 'io/console'
include Socket::Constants
include Benchmark
# --------------------------------------------------------------------------------------------------------------
#
# ASSIGNMENT 2 - Multithread vs. Select vs. Epoll
#
# SOURCE FILE:  Server.rb - A multithreaded server that illustrates amount of connections it can handle
#
# FUNCTIONS:  Berkeley Socket API
#
# VERSION:  4.0
#
# DATE: February 23rd, 2014 : 12:30AM
#
# DUE DATE: February 24th, 2014 : 12:30AM
#
# AUTHOR: Martin Javier
#
# OVERVIEW:
# This program will listen for TCP connections from client hosts. Which, it will
# wait for messages to indicate that the client has established a connection.
# During that connection it receives messages (response) are printed out.
# The messages (response) it receives will be echoed back to the client.
#
# USAGE:
# ruby Server.rb
# => Server Listening...
#
# killall "Ruby Daemon"
# => Shutting Down...
#
# REFERENCE CODE:
# http://ruby-doc.org/stdlib-1.9.3/libdoc/socket/rdoc/Socket.html
# http://www.sitepoint.com/ruby-tcp-chat/
# https://support.scinet.utoronto.ca/wiki/index.php/Using_Signals
# https://github.com/skaes/logjam_zeromq_amqp_bridge/blob/master/lib/logjam_zeromq_amqp_bridge/daemon.rb
#
# --------------------------------------------------------------------------------------------------------------
class Server

  # This initializes all the functions in Server class
  def initialize(port, ip)
    @mutex = Mutex.new
    @server = nil
    @port = port
    @ip = ip
    @total = 0
    @sockets = []
    @connection = []
    @acceptor = []
    @start = 0
    Signal.trap("INT") { shutdown }
    Signal.trap("TERM") { shutdown }
    running
    @acceptor.each(&:join)
  end

  # This method initiates the socket, accept and bind through a blocking call
  def running
    #RubyProf.measure_mode = RubyProf::PROCESS_TIME #<= Measuring process time
    #RubyProf.start #<= Measuring performance of the socket
    puts "Server Listening..."
    @start = Time.now
    @server = TCPServer.new @ip, @port
    while (connection = @server.accept)
      @mutex.synchronize do
        @acceptor << Thread.fork(connection) do |client| #<= Blocking Accept
          begin
            puts "Client #{client} Connected At #{Time.now}\n"
            port, host = client.peeraddr[1, 2]
            @sockets << client
            @connection << "#{client}:#{host}:#{port}"
            client.puts "Connection Established!"
            sleep 5
            listening(client)
          rescue EOFError
            client_list
            client.close
            puts "Client #{client} Terminated...\n"
          end
        end
      end
    end
  end

  # This method listens for incoming messages from the client which echoes it back
  def listening(client)
    while (response=client.readline) #<= gets,read does not trigger an EOFError
      Thread.new do
        data = response.size
        client.puts(response)
        puts "Client #{client} said: #{response} with #{data} bytes\n"
        @total += data
      end
    end.join
  end

  # This method grabs the list of connected clients and puts it into a list
  def client_list
    File.open("Client_List.txt", "w+") do |file|
      file.puts(@connection)
      file.close
    end
  end

  # This method grabs the signal which initiates a soft shutdown
  def shutdown
    puts "Shutting Down..."
    puts "Elapsed Time: #{Time.now - @start}"
    #result = RubyProf.stop
    #printer = RubyProf::GraphHtmlPrinter.new(result) #<= Prints Process Performance
    #file = File.open('result.html', "w")
    #printer.print(file, {})
    sleep 10
    @server.close
    exit!
  end
end


Server.new(8005, '0.0.0.0')
