"""
Run a function at a specified rate in Hz.

# Arguments
- do_work: a function handler that is executed at a specified rate and accepts no arugement.
- rate_hz: rate in Hz.
"""
function run_at(do_work::Function, rate_hz::Number)
    time_sleep = 1.0/rate_hz
    @debug "Running task at Hz" rate_hz
    while true
        do_work()
        @debug "Go to sleep" time_sleep
        sleep(time_sleep)
    end
end
