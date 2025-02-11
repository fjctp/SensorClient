using DataStructures: CircularBuffer

TimeXyzTuple = Tuple{Float64, Float64, Float64, Float64}
const LivePlotBuffer = CircularBuffer{TimeXyzTuple}
