require 'socket'
require 'thread'
require 'benchmark'


class Client
  def initialize(server)
    @mutex = Mutex.new
    @server = server
    @workers = []
    listen
    #send_message
    send_extreme_message
    @workers.join(&:join)
  end

  def listen
    @workers = Thread.new do
      loop do
        msg = @server.gets
        puts "#{msg}"
      end
    end
  end

  def send_message
    puts "Enter Message"
    @workers = Thread.new do
      loop do
        msg = $stdin.gets.chomp
        @server.puts(msg)
      end
    end
  end

  def send_extreme_message
    puts "Enter Extreme Message"
    @workers = Thread.new do
      loop do
        msg = gets.chomp
        puts "Enter Repetition Amount"
        number = gets.to_i
        number.times {@server.puts(msg)}
      end
    end
  end
end



puts "Specify Ports"
ports = gets.to_i

puts "How many clients?"
number = gets.to_i
number.times do
    server = TCPSocket.new("localhost", ports)
    Client.new(server)
end












