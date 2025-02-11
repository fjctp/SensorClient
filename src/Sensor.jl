using HTTP.WebSockets

# Sensor defines required information to connect to a SensorServer.
struct Sensor
    address::String
    port::String
    kind::String
end

# get_ws_url() returns a valid websocket server URL.
function get_ws_url(s0::Sensor)
    addr = """ws://$(s0.address):$(s0.port)/"""
    if occursin("gps", s0.kind)
        addr * "gps"
    else
        addr * """sensor/connect?type=$(s0.kind)"""
    end
end

# receive()
function receive(handle::Function, s0::Sensor)
    isgps = s0.kind == "gps"

    url = get_ws_url(s0)
    @debug "Connecting to "*url
    WebSockets.open(url) do ws
        @info "Connected to "*string(ws.request.url)

        if isgps
            @info "Request for last known GPS location."
            WebSockets.send(ws, "getLastKnowLocation")
        end

        while !WebSockets.isclosed(ws)
            raw_msg = try
                WebSockets.receive(ws)
            catch err
                # socket is closed.
                @info s0.kind*" disconnected."
                return
            end
            @debug "Received raw message: " raw_msg
            sdata = SensorData(raw_msg)
            @debug "Parsed data: " sdata
            handle(sdata)
        end
    end
end
