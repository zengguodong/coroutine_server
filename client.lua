--client.lua

-- send user input data to server and print data from server

local socket = require("socket")

local host = "127.0.0.1"
local port = 8888
local sock = assert(socket.connect(host, port))
sock:settimeout(0)



function main()

	print("Press enter after input something:")

	local input, recvt, sendt, status

	while true do
		input = io.read()
		if #input > 0 then
			assert(sock:send(input .. "\n"))
		end

		recvt, sendt, status = socket.select({sock}, nil, 1)
		while #recvt > 0 do

			local response, receive_status = sock:receive()

			if receive_status ~= "closed" then
				if response then
					print ('recv from server:'..response)
					recvt, sendt, status = socket.select({sock}, nil, 1)
				end
			else
				break
			end
		end

	end

end

main()
