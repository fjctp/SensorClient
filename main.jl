using SensorClient
using GLMakie

function main()
    # Define parameters
    address = get(ENV, "WS_ADDRESS", "localhost")
    port = get(ENV, "WS_PORT", "8080")
    plot_rate_hz = parse(Float32, get(ENV, "UPDATE_HZ", "30"))
    buffer_sec = parse(Float32, get(ENV, "BUFFER_SEC", "4"))
    @info "Loading Config:" address port plot_rate_hz buffer_sec

    sensor_cfgs = [
        # name, data rate in Hz
        ("android.sensor.accelerometer", 500.0, "Body Accel", "m/s/s", ["x", "y", "z"]), 
        ("android.sensor.gyroscope", 500.0, "PQR", "deg/s", ["p", "q", "r"]),
        ("android.sensor.magnetic_field", 100.0, "Magnetic Field", "nT", ["x", "y", "z"]),
        ("gps", 1.0, "GPS", "deg or m", ["lat", "lon", "alt"]),
    ]

    # Create Sensors
    sensors = map(sensor_cfgs) do cfg
        SensorClient.Sensor(address, port, cfg[1])
    end 

    # Create data buffers for live plot.
    buffers = map(sensor_cfgs) do cfg
        data_rate_hz = cfg[2]
        buffer_size = round(Int, buffer_sec*data_rate_hz)
        SensorClient.LivePlotBuffer(buffer_size)
    end 

    # Create locks to sync threads.
    buffer_locks = map(sensor_cfgs) do _
        ReentrantLock()
    end 

    # Create live figures.
    live_figs = map(sensor_cfgs) do cfg
        axis_names = [cfg[3]* " (" * cfg[4] *")", "Sample Time (s)"]
        ff = SensorClient.LiveFigure(axis_names)

        # Show figures on the same screen.
        display(GLMakie.Screen(), ff.f)
        ff
    end

    # Start threads to receive data from websockets.
    for ind in eachindex(sensors)
        Threads.@spawn SensorClient.receive(sensors[ind]) do sdata
            val = [sdata.timeElapsed, sdata.val[1], sdata.val[2], sdata.val[3]]
            d = SensorClient.TimeXyzTuple(val)
            @debug "Got data" d
            @lock buffer_locks[ind] push!(buffers[ind], d)
        end
    end

    # Update figures in main thread.
    # - creatation of Figure/Axis object and update!() has be on the same thread. Otherwise, OpenGL error... 
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
