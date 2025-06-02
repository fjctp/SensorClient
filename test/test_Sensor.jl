using SensorClient: Sensor, receive

function main()
    waitsec = 5.0
    sensor_types = ["android.sensor.accelerometer", "gps"]

    # Create Sensor struct
    #TODO: check gps as well or other type in a separated test.
    address = get(ENV, "WS_ADDRESS", "localhost")
    port = get(ENV, "WS_PORT", "8080")
    cli = Sensor(address, port, sensor_types[1])

    # Connect to server
    @info "Connecting to server"
    @Threads.spawn receive(cli) do data_s
        @info data_s
    end

    # Wait
    @info "Wait for "*string(waitsec)*"sec"
    sleep(waitsec)
    @info "Test ended"
end

main()
