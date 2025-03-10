using JSON

"""
A generic sensor data values, [data_x, data_y, data_z]
"""
SensorDataVal = Tuple{Float32, Float32, Float32}

"""
A generic sensor data struct

# Fields
- timeElapsed: time of this measurement in seconds of elapsed realtime since system boot. (For all sensor)
- timeUnixEpoch: the Unix epoch time of this location fix, in seconds since the start of the Unix epoch (00:00:00 January 1, 1970 UTC). (For GPS sensor only)
- kind: A valid sensor type defined by SensorSever.
- val: a generic sensor data values, see `SensorDataVal`.

# Constructor, SensorData(raw::String)
- raw: raw JSON string received from websocket.
"""
struct SensorData
    timeElapsed::Float64
    timeUnixEpoch::Float64
    kind::String
    val::SensorDataVal

    function SensorData(raw::String)
        # Parse raw JSON string.
        d0 = JSON.parse(raw)

        if haskey(d0, "latitude")
            # For GPS measurements.
            timeElapsed = d0["elapsedRealtimeNanos"] / 1.0e9 # convert from nano-second to second
            timeUnixEpoch = d0["time"] / 1.0e6 # convert from milli-second to second
            val = SensorDataVal((d0["latitude"], d0["longitude"], d0["altitude"]))

            new(timeElapsed, timeUnixEpoch, "gps", val)
        elseif haskey(d0, "values")
            # For other measurements.
            timeElapsed = d0["timestamp"] / 1.0e9
            timeUnixEpoch = 0.0 # No data for general sensor, only for GPS.
            val = SensorDataVal(d0["values"])

            new(timeElapsed, timeUnixEpoch, "xyz", val)
        else
            @error "Unexpected raw data" d0
        end
    end
end

"""
Custom show function for SensorData. Used by println.
"""
function Base.show(io::IO, data::SensorData)
    print(io, "SensorData($(data.timeElapsed), $(data.timeUnixEpoch), $(data.kind), $(data.val))")
end
