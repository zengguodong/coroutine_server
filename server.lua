-- server.lua
--listen connection from client, and make a coroutine for each connection
--each coroutine recv data from client and send data back to client

local socket = require("socket")

local host = "127.0.0.1"
local port = "8888"
local connections = {}
local threads = {}



function receive_data(sock_id)

	local conn = connections[sock_id]
	if conn ~= nil then

		local recvt, t, status = socket.select({conn}, nil, 1)
        if #recvt > 0 then
            local receive, receive_status = conn:receive()

            if receive_status ~= "closed" then
                if receive then
                    assert(conn:send(receive .. "\n"))
                    print("Receive Client " .. sock_id.. " : " ..receive)
                end
			--disconnect
			else
				print("Client " .. sock_id .. " disconnect!")
                connections[sock_id].close()
				connections[sock_id] = nil
				threads[sock_id] = nil
			end
        end
		--yield, stop execution of this coroutine
		coroutine.yield()
	end
end


--handle data from client: send data back to client
function connection_handler(sock_id)

	while true do
		--print ('connection_handler.. id=' .. sock_id)
		local conn = connections[sock_id]
		if conn == nil then
			break
		end

		local data, status = receive_data(sock_id)

	end

end


--create coroutine to handle data from client
function create_handler(sock_id)
	--print 'create_handler..'

	local handler = coroutine.create(function ()
		connection_handler(sock_id)
	end)
    return handler

end



function accept_connection(sock_id, conn)
    print("accepted new socket ,id = " .. sock_id)

    connections[sock_id] = conn
	threads[sock_id] = create_handler(sock_id)
end



--schedule all clients
function dispatch()

	for _sock_id, _thread in ipairs(threads) do
		--print ('dispatch, _sock_id = '.. _sock_id)
		coroutine.resume(threads[_sock_id])
	end

end



function start_server()
	local server = assert(socket.bind(host, port, 1024))
	print("Server Start " .. host .. ":" .. port)
	server:settimeout(0)

	local conn_count = 0

	while true do

		--accept new connection
		local conn = server:accept()
		if conn then
			conn_count = conn_count + 1
			accept_connection(conn_count, conn)
		end

		--deal data from connection
		dispatch()
	end


end

function main()
	start_server()
end

main()
