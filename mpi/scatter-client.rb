require 'rubygems'
require 'backports'
require 'bud'
require_relative 'scatter'

class Client
  include Bud
  include Scatter

  def initialize(server, sender, num_receivers, id, opts={})
    @server = server
    @sender = sender.to_i
    @num_receivers = num_receivers.to_i
    @fn_ip_port = "127.0.0.1:1235"
    @client_id = id.to_i
    @data = [1, 2, 3, 4]
    puts "Initialized, client #" + @client_id.to_s
    super opts
  end

  def wait()
    return true
  end

  def hello()
    puts("HELLO")
    return true
  end

  def ping(s)
    puts(s)
    return true
  end
end

server = ARGV[0]
sender = ARGV[1]
num_receivers = ARGV[2]
id = ARGV[3]
ip, port = server.split(":")
puts "Server address: #{server}"
program = Client.new(server, sender, num_receivers, id, :ip=>ip, :port=>port, :stdin => $stdin)
program.run_fg
