require 'socket'
require 'thread'
require 'benchmark'
#require 'ruby-prof'
require 'io/console'
include Socket::Constants
include Benchmark
# --------------------------------------------------------------------------------------------------------------
#
# ASSIGNMENT 2 - Multithread vs. Select vs. Epoll
#
# SOURCE FILE: Client.rb - A multithreaded client that illustrates amount of connections(sockets) it can connect
#
# FUNCTIONS:  Berkeley Socket API
#
# VERSION: 4.0
#
# DATE: February 23rd, 2014 : 12:30AM
#
# DUE DATE: February 24th, 2014 : 12:30AM
#
# AUTHOR: Martin Javier
#
# OVERVIEW:
# This program will connect to the server through TCP connections. Which, it will
# wait for messages to indicate that the client successfully connected.
# During that connection the client sends a message (message) to the server.
# The messages (message) will be echoed back by the server.
#
# USAGE:
# ruby Client.rb
# => Specify Port
# <User Input>
# => How many clients?
# <User Input>
# => What's your message?
# <User Input>
# => How many times would you like to repeat the message?
# <User Input>
#
# kill -2 <pid> Client.rb
#
# REFERENCE CODE:
# http://ruby-doc.org/stdlib-1.9.3/libdoc/socket/rdoc/Socket.html
# http://www.sitepoint.com/ruby-tcp-chat/
# https://support.scinet.utoronto.ca/wiki/index.php/Using_Signals
# https://github.com/skaes/logjam_zeromq_amqp_bridge/blob/master/lib/logjam_zeromq_amqp_bridge/daemon.rb
#
# --------------------------------------------------------------------------------------------------------------
class Client

  # This initializes all the functions in Client class
  def initialize(server, message, repeat)
    @server = server
    @req = nil
    @res = nil
    @start = 0
    @connections = []
    Signal.trap("INT") { shutdown(server) }
    Signal.trap("TERM") { shutdown(server) }
    listening
    sending(message, repeat)
    @req.join
    @res.join
  end

  # This method initiates a listen for incoming responses from the server
  def listening
    @start = Time.now
    #RubyProf.measure_mode = RubyProf::PROCESS_TIME #<= Measuring process time
    #RubyProf.start #<= Measuring performance of the socket
    @res = Thread.new do
      count = 0
      while (message = @server.readline)
        count += 1
        puts "Server: #{message}"
        puts "Amount Of Responses #{count}"
      end
    end
  end

  # This method initiates a send and the number of repetitions it will send to the server
  def sending(message, repeat)
    @req = Thread.new do
      count = 0
      repeat.times do
        count += 1
        @server.puts message
        puts "Amount Of Requests #{count}"
      end
    end
  end

  # This method prints to a file with number amount of transactions
  def server_list
    File.open("Server_List.txt", "w+") do |file|
      file.puts(@connection)
      file.close
    end
  end

  def client_list
    File.open("Client_List.txt", "w+") do |file|
      file.puts(@connection)
      file.close
    end
  end

  # This method grabs the signal which initiates a soft shutdown
  def shutdown(server)
    puts "Shutting Down..."
    puts "Elapsed Time: #{Time.now - @start}"
    server_list
    #result = RubyProf.stop
    #printer = RubyProf::GraphHtmlPrinter.new(result) #<= Prints Process Performance
    #file = File.open("client_result.html", "w+")
    #printer.print(file, :min_percent => 2)
    sleep 10
    server.close
    exit!
  end
end


puts "Specify Port"
port = gets.to_i

puts "How many clients?"
number = gets.to_i

puts "What's your message?"
message = gets.to_s.chomp

puts "How many times would you like to repeat the message?"
repeats = gets.to_i

acceptor = nil
begin
  number.times do |i|
    acceptor = Thread.new do
      begin
        server = TCPSocket.new 'localhost', port
        #noinspection RubyArgCount
        Client.new(server, message, repeats)
        server.flush
        @connections << server
      rescue EOFError
        server.close
        puts "Done!"
      end
    end
    puts "Request: #{i + 1} done!"
  end
rescue SystemExit, Interrupt #<= Catching Control-C
  raise e
rescue Exception => e
  puts "Connection Terminated!"
ensure
  acceptor.join
end












