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
