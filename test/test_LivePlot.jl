using SensorClient
using GLMakie
using Dates

function main()
    generateData = () -> TimeXyzTuple(
        [Dates.datetime2unix(Dates.now()), rand(), rand(), rand()])

    lk = ReentrantLock()
    b = LivePlotBuffer(10)

    @Threads.spawn run_at(5.0) do
        @lock lk push!(b, generateData())
    end

    lf = LiveFigure(["Data", "Sample Time"])
    for _ = 1:10
        update!(lf, b, lk)
        sleep(1.0/2.0)
    end
    
    sleep(1.0)
    GLMakie.closeall()
end

main()
