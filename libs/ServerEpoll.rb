require 'rubygems'
require 'em/pure_ruby'
require 'eventmachine'
require 'socket'
require_relative 'Counter'
# --------------------------------------------------------------------------------------------------------------
#
# ASSIGNMENT 2 - Multithread vs. Select vs. Epoll
#
# SOURCE FILE:  ServerEpoll.rb  - A server that illustrates amount of connections(sockets) it can connect through
#                                 IO.Epoll
#
# FUNCTIONS:  Berkeley Socket API, Reactor Pattern - EventMachine
#
# VERSION: 3.0
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
# This program implements the EventMachine library which, allows an asynchronous
# non-blocking accept which done through a single thread built-in. EventMachine
# is defaulted to using epoll when handling non-blocking connections.
#
# USAGE:
# ruby SelectEpoll.rb
# =>  Server Listening...
#
# kill -2 <pid> SelectEpoll.rb
#
# REFERENCE CODE:
# http://www.ruby-doc.org/gems/docs/k/ktools-0.0.3/Kernel/Epoll.html
# http://ruby-doc.org/stdlib-1.9.3/libdoc/socket/rdoc/Socket.html
# http://eventmachine.rubyforge.org/file.GettingStarted.html
# https://github.com/eventmachine/eventmachine/wiki/Code-Snippets
# http://eventmachine.rubyforge.org/docs/EPOLL.html
#
# NOTE:
# DO NOT test this server if the machine does not support epoll!
#
# --------------------------------------------------------------------------------------------------------------
class ServerEpoll < EM::Connection

  # This initializes the counter class
  def initialize(counter)
    @total = 0
    @total_data = 0
    @counter = counter
    @client = nil
  end

  # This called by the event loop after the network connection is set
  def post_init
    port, *ip_parts = get_peername[2,6].unpack "nC4"
    ip = ip_parts.join('.')
    @client = ip,":#{port}"
    puts "Client Connected: #{@client}"

    operation = proc do
      File.open('client_list.txt', "w") do |f|
        begin
          f.puts(@client)
        ensure
          f.close
        end
      end
    end

    callback = proc do
      puts "I wrote a file!"
    end

    EventMachine.next_tick(operation)
    EventMachine.defer(operation, callback)
  end

  # This called by the event loop after it receives data from the connection
  def receive_data data
    @total += 1
    @total_data += data.length
    @counter.total_data = data.length
    send_data "Client Said: #{data} with #{data.size} bytes\n"
    close_connection if data =~ /quit/i
  end

  # This disconnects the connection between the client and server
  def unbind
    puts "Client Disconnected: #{@client}"
  end

  # In order to get around ruby's hard coded file descriptor size to 1024.
  # EventMachine allows a simple method to call the IO.epoll
  EventMachine.epoll
  # EventMachine allows the file descriptor size to be changed.
  EventMachine.set_descriptor_table_size(50000)
  EventMachine.run {
    start = Time.now
    count = Counter.new
    Signal.trap("INT") {
      puts "Time Elapsed: #{Time.now - start}"
      sleep 5
      EventMachine.stop
    }
    Signal.trap("TERM") {
      puts "Time Elapsed: #{Time.now - start}"
      sleep 5
      EventMachine.stop
    }
    EventMachine.start_server "0.0.0.0", 8005, ServerEpoll, count
    puts "Server Listening..."
    EventMachine.add_periodic_timer(30) { puts "Count=#{count.inspect}" }
  }
end