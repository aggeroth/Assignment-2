require 'rubygems'
require 'rev'
HOST = '0.0.0.0'
PORT = 8005

class SelectServer < Rev::TCPSocket

  def on_connect
    puts "#{remote_addr}:#{remote_port} connected"
    client_list(remote_addr,remote_port)
  end

  def on_close
    puts "#{remote_addr}:#{remote_port} disconnected"
  end

  def on_read(message)
    write message
  end

  def client_list(ip, port)
    File.open("Client_List_Select.txt", "w") do |file|
      file.write("Client: #{ip},#{port}")
      file.close
    end
  end

end


server = Rev::TCPServer.new(HOST, PORT, SelectServer)
server.attach(Rev::Loop.default)

puts "Echo server listening on #{HOST}:#{PORT}"
Rev::Loop.default.run