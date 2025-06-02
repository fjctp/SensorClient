using GLMakie

"""
A figure including multiple axes.
"""
mutable struct LiveFigure
    f::Figure
    ax_v::Vector{Axis}

    function LiveFigure(axis_names::Vector{String}=["Data", "Sample Time"])
        # Create and show a figure.
        f = Figure()

        # Create a SensorAxis for each data buffer object.
        ax_v = map(eachindex(axis_names), axis_names) do ind_axis, axis_name
            Axis(f[ind_axis, 1], xlabel="Time", ylabel=axis_name)
        end

        # Create an instance of LiveFigure.
        return new(f, ax_v)
    end
end

"""
Plot sample times from a buffer.

# Arguments
- lf: a `LiveFigure` where the "sample time" plot is updated.
- buffer: a `LivePlotBuffer` where its data buffer is used to update a plot.
- lk: a reentrant lock to prevent data racing between threads.
"""
function plotDeltaTime!(lf::LiveFigure, buffer::LivePlotBuffer, lk::ReentrantLock)
    if isempty(buffer)
        # Skip if no data is ready
        return false
    end
    ax = lf.ax_v[2]

    # Get timestamp from each measurement and offset it by last measurement.
    # Last measurement should be 0 second, and first measurement should be second buffered.
    timestamp = Vector{Float32}
    @lock lk timestamp = getindex.(buffer, 1) # timestamp from each `TimeXyz` tuple.
    timestamp .= timestamp .- timestamp[end]
    dt = diff(timestamp) # Get time between samples.
    dt = [dt[1]; dt] # append to the front. diff() returns a vector size of N-1.
    
    # Clear and plot.
    empty!(ax)
    lines!(ax, timestamp, dt, color=:blue)

    return true
end

"""
Plot sensor measurements from a buffer.

# Arguments
- lf: a `LiveFigure` where the "sample time" plot is updated.
- buffer: a `LivePlotBuffer` where its data buffer is used to update a plot.
- lk: a reentrant lock to prevent data racing between threads.
- sig_names: signal name. There should be three elements. Default: ["x", "y", "z"]
- colors: line color. There should be three elements. Default: [:blue, :red, :green]
"""
function plotBuffer!(lf::LiveFigure, buffer::LivePlotBuffer, 
    lk::ReentrantLock, sig_names::Vector{String} = ["x", "y", "z"], 
    colors::Vector{Symbol} = [:blue, :red, :green])

    if isempty(buffer)
        # Skip if no data is ready
        return false
    end
    ax = lf.ax_v[1]
    
    # Get timestamp from each measurement and offset it by last measurement.
    # Last measurement should be 0 second, and first measurement should be second buffered.
    xx = Vector{Float32}
    yy = Matrix{Float32}
    @lock lk begin
        xx = getindex.(buffer, 1) .- buffer[end][1] # timestamp from each `TimeXyz` tuple.
        yy = getindex.(buffer, [2 3 4]) # measurements from each `TimeXyz` tuple.
    end

    # Clear and plot.
    empty!(ax)
    for ind = 1:3
        lines!(ax, xx, yy[:, ind], label=sig_names[ind], color=colors[ind])
    end

    return true
end

"""
Update plots in a LiveFigure.

# Arguments
- lf: a `LiveFigure` where the "sample time" plot is updated.
- buffer: a `LivePlotBuffer` where its data buffer is used to update a plot.
- lk: a reentrant lock to prevent data racing between threads.
"""
function update!(lf::LiveFigure, b::LivePlotBuffer, lk::ReentrantLock)
    return plotBuffer!(lf, b, lk) && plotDeltaTime!(lf, b, lk)
end
