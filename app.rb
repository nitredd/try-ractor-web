require 'socket'

server = TCPServer.new('127.0.0.1', 8080)
cpu_count = 4

# Create worker ractors
workers = cpu_count.times.map do
  Ractor.new do
    loop do
      # Receive the moved TCPSocket from the main thread
      s = Ractor.recv 
      request = s.gets
      
      # Respond to the HTTP client
      s.print "HTTP/1.1 200 OK\r\n"
      s.print "Content-Type: text/plain\r\n\r\n"
      s.print "Hello from Ractor worker!\n"
      s.close
    end
  end
end

puts "Server running on port 8080..."

# Main loop accepts connections and delegates to workers round-robin
i = 0
loop do
  conn, _ = server.accept
  # Pass the socket to a worker and transfer ownership using move: true
  workers[i].send(conn, move: true)
  i = (i + 1) % workers.length
end
