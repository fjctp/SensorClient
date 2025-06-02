"""
SensorClient package receives and plots data from a SensorServer running on an Android device.

# Sensor
- receive(handle::Function, s0::Sensor)

# SensorData
- SensorData(raw_JSON_msg::String)

# LivePlotBuffer
- LivePlotBuffer(size::Uint32)

# LiveFigure
- update!(lf::LiveFigure, b::LivePlotBuffer, lk::ReentrantLock)

"""
module SensorClient

# Include files
include("Sensor.jl")
include("SensorData.jl")
include("LivePlotBuffer.jl")
include("LivePlot.jl")
include("Scheduler.jl")

# Export data type and functions outside of the module.
# Same order as the included files.
export 
    Sensor, receive, 
    SensorData, 
    LivePlotBuffer, TimeXyzTuple, 
    LiveFigure, update!, 
    run_at
end
