using SensorClient
using GLMakie

"""
Connect to a SensorServer and plot sensor measurements in real-time.
- Linear accelerations in body frame.
- Angular rate in body frame.
- Magnetic field in body frame.
- GPS coordinates (latitude, longitude, altitude).
"""
function main()
    # Define user parameters
    address = get(ENV, "WS_ADDRESS", "localhost")
    port = get(ENV, "WS_PORT", "8080")
    plot_rate_hz = parse(Float32, get(ENV, "UPDATE_HZ", "30"))
    buffer_sec = parse(Float32, get(ENV, "BUFFER_SEC", "4"))
    @info "Loading Config:" address port plot_rate_hz buffer_sec

    # Define sensor parameters
    sensor_cfgs = [
        # Sensor kind, data rate in Hz, sensor name, measurement unit, signal names
        ("android.sensor.accelerometer", 500.0, "Body Accel", "m/s/s", ["x", "y", "z"]), 
        ("android.sensor.gyroscope", 500.0, "PQR", "deg/s", ["p", "q", "r"]),
        ("android.sensor.magnetic_field", 100.0, "Magnetic Field", "nT", ["x", "y", "z"]),
        ("gps", 1.0, "GPS", "deg or m", ["lat", "lon", "alt"]),
    ]

    # Create a `Sensor` for each sensor configuration.
    sensors = map(sensor_cfgs) do cfg
        SensorClient.Sensor(address, port, cfg[1])
    end 

    # Create a buffer, `LivePlotBuffer`, for each `Sensor`.
    buffers = map(sensor_cfgs) do cfg
        data_rate_hz = cfg[2]
        buffer_size = round(Int, buffer_sec*data_rate_hz)
        SensorClient.LivePlotBuffer(buffer_size)
    end 

    # Create a lock for each `Sensor`.
    buffer_locks = map(sensor_cfgs) do _
        ReentrantLock()
    end 

    # Create a live figure, `LiveFigure`, for each `Sensor`.
    live_figs = map(sensor_cfgs) do cfg
        axis_names = [cfg[3]* " (" * cfg[4] *")", "Sample Time (s)"]
        ff = SensorClient.LiveFigure(axis_names)

        # Show a figure on a defined screen. 
        # Ensure that all the figures are visible on "main" screen.
        display(GLMakie.Screen(), ff.f)
        ff
    end

    # Start a thread for each `Sensor` to receive data.
    for ind in eachindex(sensors)
        Threads.@spawn SensorClient.receive(sensors[ind]) do sdata
            val = [sdata.timeElapsed, sdata.val[1], sdata.val[2], sdata.val[3]]
            d = SensorClient.TimeXyzTuple(val)
            @debug "Got data" d
            @lock buffer_locks[ind] push!(buffers[ind], d)
        end
    end

    # Update figures in main thread.
    # - Creatation of Figure/Axis object and update!() has be on the same thread. Otherwise, OpenGL error... 
    SensorClient.run_at(plot_rate_hz) do
        for ind in eachindex(sensors)
            try
                SensorClient.update!(live_figs[ind], buffers[ind], buffer_locks[ind])
            catch err
                @error err
            end
        end
    end
end

main()
