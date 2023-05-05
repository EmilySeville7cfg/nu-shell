export def "log CRITICAL_LEVEL" [] {
	50
}

export def "log ERROR_LEVEL" [] {
	40
}

export def "log WARNING_LEVEL" [] {
	30
}

export def "log INFO_LEVEL" [] {
	20
}

export def "log DEBUG_LEVEL" [] {
	10
}

def parse-string-level [level: string] {
    (
        if $level == "CRITICAL" {
            log CRITICAL_LEVEL
        } else if $level == "CRIT" {
            log CRITICAL_LEVEL
        } else if $level == "ERROR" {
            log ERROR_LEVEL
        } else if $level == "WARNING" {
            log WARNING_LEVEL
        } else if $level == "WARN" {
            log WARNING_LEVEL
        } else if $level == "INFO" {
            log INFO_LEVEL
        } else if $level == "DEBUG" {
            log DEBUG_LEVEL
        } else {
            log INFO_LEVEL
        }
    )
}

export def "log CRITICAL_LEVEL_PREFIX" [] {
    "CRT"
}

export def "log ERROR_LEVEL_PREFIX" [] {
    "ERR"
}

export def "log WARNING_LEVEL_PREFIX" [] {
    "WRN"
}

export def "log INFO_LEVEL_PREFIX" [] {
    "INF"
}

export def "log DEBUG_LEVEL_PREFIX" [] {
    "DBG"
}   

def parse-int-level [level: int] {
    (
        if $level >= (log CRITICAL_LEVEL) {
            log CRITICAL_LEVEL_PREFIX
        } else if $level >= (log ERROR_LEVEL) {
            log ERROR_LEVEL_PREFIX
        } else if $level >= (log WARNING_LEVEL) {
            log WARNING_LEVEL_PREFIX
        } else if $level >= (log INFO_LEVEL) {
            log INFO_LEVEL_PREFIX
        } else {
            log DEBUG_LEVEL_PREFIX
        }
    )
}

def current-log-level [] {
    let env_level = ($env | get --ignore-errors NU_LOG_LEVEL | default (log INFO_LEVEL))

    try {
        ($env_level | into int)
    } catch {
        parse-string-level $env_level
    }
}

def now [] {
    date now | date format "%Y-%m-%dT%H:%M:%S%.3f"
}

def log-formatted [
    color: string,
    prefix: string,
    message: string
] {
    print --stderr $"($color)($prefix)|(now)|(ansi u)($message)(ansi reset)"
}

# Log a critical message
export def "log critical" [
    message: string, # A message
    --short (-s) # Whether to use a short prefix
] {
    if (current-log-level) > (log CRITICAL_LEVEL) {
        return
    }

    let prefix = (if $short {
	    "C"
    } else {
        "CRT"
    })
    log-formatted (ansi red_bold) $prefix $message
}

# Log an error message
export def "log error" [
    message: string, # A message
    --short (-s) # Whether to use a short prefix
] {
    if (current-log-level) > (log ERROR_LEVEL) {
        return
    }

    let prefix = (if $short {
        "E"
    } else {
        "ERR"
    })
    log-formatted (ansi red) $prefix $message
}

# Log a warning message
export def "log warning" [
    message: string, # A message
    --short (-s) # Whether to use a short prefix
] {
    if (current-log-level) > (log WARNING_LEVEL) {
        return
    }

    let prefix = (if $short {
        "W"
    } else {
        "WRN"
    })
    log-formatted (ansi yellow) $prefix $message
}

# Log an info message
export def "log info" [
    message: string, # A message
    --short (-s) # Whether to use a short prefix
] {
    if (current-log-level) > (logINFO_LEVEL) {
        return
    }

    let prefix = (if $short {
        "I"
    } else {
        "INF"
    })
    log-formatted (ansi default) $prefix $message
}

# Log a debug message
export def "log debug" [
    message: string, # A message
    --short (-s) # Whether to use a short prefix
] {
    if (current-log-level) > (log DEBUG_LEVEL) {
        return
    }

    let prefix = (if $short {
        "D"
    } else {
        "DBG"
    })
    log-formatted (ansi default_dimmed) $prefix $message
}

# Log a message with a specific format and verbosity level
# 
# Format reference:
# - %MSG% will be replaced by $message
# - %DATE% will be replaced by the timestamp of log in standard Nushell's log format: "%Y-%m-%dT%H:%M:%S%.3f"
# - %LEVEL% will be replaced by the standard Nushell's log verbosity prefixes, e.g. "CRT"
#
# Examples:
# - std log custom "my message" $"(ansi yellow)[%LEVEL%]MY MESSAGE: %MSG% [%DATE%](ansi reset)" (std log WARNING_LEVEL)
export def "log custom" [
    message: string, # A message
    format: string, # A format
    log_level: int # A log level
] {
    if (current-log-level) > ($log_level) {
        return
    }

    print --stderr ($format |
        str replace "%MSG%" $message |
        str replace "%DATE%" (now) |
        str replace "%LEVEL%" (parse-int-level $log_level | into string))
}