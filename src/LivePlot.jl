using GLMakie

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

function plotDeltaTime!(lf::LiveFigure, buffer::LivePlotBuffer, lk::ReentrantLock)
    if isempty(buffer)
        return false
    end
    ax = lf.ax_v[2]

    timestamp = Vector{Float32}
    @lock lk timestamp = getindex.(buffer, 1)
    timestamp .= timestamp .- timestamp[end]
    dt = diff(timestamp)
    dt = [dt[1]; dt]
    
    empty!(ax)
    lines!(ax, timestamp, dt, color=:blue)

    return true
end

function plotBuffer!(lf::LiveFigure, buffer::LivePlotBuffer, 
    lk::ReentrantLock, sig_names::Vector{String} = ["x", "y", "z"], 
    colors::Vector{Symbol} = [:blue, :red, :green])

    if isempty(buffer)
        return false
    end
    ax = lf.ax_v[1]
    empty!(ax)
    
    xx = Vector{Float32}
    yy = Matrix{Float32}
    @lock lk begin
        xx = getindex.(buffer, 1) .- buffer[end][1]
        yy = getindex.(buffer, [2 3 4])
    end
    
    for ind = 1:3
        lines!(ax, xx, yy[:, ind], 
            label=sig_names[ind], color=colors[ind])
    end

    return true
end

function update!(lf::LiveFigure, b::LivePlotBuffer, lk::ReentrantLock)
    return plotBuffer!(lf, b, lk) && plotDeltaTime!(lf, b, lk)
end
