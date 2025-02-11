function run_at(fun_loop::Function, rate_hz_update::Number)
    time_sleep = 1.0/rate_hz_update
    @debug "Running task at Hz" rate_hz_update
    while true
        fun_loop()
        @debug "Go to sleep" time_sleep
        sleep(time_sleep)
    end
end