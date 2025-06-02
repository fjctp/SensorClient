using DataStructures: CircularBuffer

"""
Keep a sensor measurement at a given time. (Used in `LivePlotBuffer`)

- [Timestamp in second, data in X-axis, data in Y-axis, data in Z-axis]
"""
TimeXyzTuple = Tuple{Float64, Float64, Float64, Float64}

"""
A buffer of sensor measurements. (Used in `LiveFigure`)

# Arguments
- size: Size of the buffer.
"""
const LivePlotBuffer = CircularBuffer{TimeXyzTuple}
