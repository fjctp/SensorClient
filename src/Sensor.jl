using HTTP.WebSockets

"""
A immutable struct holding SensorServer information.

# Fields
- address: websocket address of SensorSever.
- port: websocket port of SensorSever.
- kind: A valid sensor type defined by SensorSever.
"""
struct Sensor
    address::String
    port::String
    kind::String
end

"""
Get a valid websocket server URL from a `Sensor`.

# Arguments
- s0: a `Sensor` struct that define SensorServer information.
"""
function get_ws_url(s0::Sensor)
    addr = """ws://$(s0.address):$(s0.port)/"""
    if occursin("gps", s0.kind)
        addr * "gps"
    else
        addr * """sensor/connect?type=$(s0.kind)"""
    end
end

"""
Register a websocket message handler for a `Sensor`.

# Arguments
- handle: a function handler that accepts an arugement with type of `SensorData`.
- s0: a `Sensor` struct that define SensorServer information.
"""
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
