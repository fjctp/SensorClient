using JSON

SensorDataVal = Tuple{Float32, Float32, Float32}

struct SensorData
    timeElapsed::Float64 # Time of this measurement in seconds of elapsed realtime since system boot.
    timeUnixEpoch::Float64 # The Unix epoch time of this location fix, in seconds since the start of the Unix epoch (00:00:00 January 1, 1970 UTC).
    kind::String
    val::SensorDataVal

    function SensorData(raw::String)
        d0 = JSON.parse(raw)
        if haskey(d0, "latitude")
            timeElapsed = d0["elapsedRealtimeNanos"] / 1.0e9
            timeUnixEpoch = d0["time"] / 1.0e6
            val = SensorDataVal((d0["latitude"], d0["longitude"], d0["altitude"]))

            new(timeElapsed, timeUnixEpoch, "gps", val)
        elseif haskey(d0, "values")
            timeElapsed = d0["timestamp"] / 1.0e9
            timeUnixEpoch = 0.0 # No data for general sensor, only for GPS.
            val = SensorDataVal(d0["values"])

            new(timeElapsed, timeUnixEpoch, "xyz", val)
        else
            @error "Unexpected raw data" d0
        end
    end
end

# Custom show function for println.
function Base.show(io::IO, data::SensorData)
    print(io, "SensorData($(data.timeElapsed), $(data.timeUnixEpoch), $(data.kind), $(data.val))")
end
