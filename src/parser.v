module main

import os
import progressbar
import net.http

fn parse_config(path string) {
    // Read all lines from the file, propagating any error
    lines := os.read_lines(path) or {
        panic(err)
    }
    
    // Initialize the remotes and local's array
    mut remotes := [][]string{}
    mut locals := [][]string{}

    // Line count to track errors
    mut line_count := 0
    
    // Process each line
    for line in lines {
        line_count = line_count + 1
        trimmed := line.trim_space()
        
        // Skip empty lines and comments
        if trimmed == '' || trimmed.starts_with('//') {
            continue
        }
        
        // Parse the line with the custom parser
        parts := parse_line(trimmed)
        if parts.len == 0 {
            println('Invalid statement on line ${line_count}: ${trimmed}')
            return
        }

        // Handle declare statements
        if parts[0] == 'declare' {
            continue
        }

        // Handle conf lines
        if parts[0] == 'conf' {
            if parts.len != 4 { // Expect ["conf", "type", "path", "value"]
                println('Invalid conf statement on line ${line_count}: ${trimmed}')
                return
            }
            if parts[1] == 'remote' {
                if !parts[3].starts_with('http') {
                    println("ERROR: On line ${line_count}, remote ${parts[3]} does not appear to be a valid url.")
                    return
                }
                remotes << [parts[2], parts[3]]
            }
            if parts[1] == 'local' {
                if os.exists(parts[3]) == false {
                    println("ERROR: On line ${line_count}, file ${parts[3]} does not exist.")
                    return
                }
                locals << [parts[2], parts[3]]
            }
            // Add handling for 'local' if needed
        }
    }
    task_runner(remotes, locals)
}

fn task_runner(remotes [][]string, locals [][]string) {
    // This is the number the progressbar module will use to interpret the number of steps.
    mut step_number := 0
    pb := progressbar.new(remotes.len + locals.len, 50)
    
    println("Starting task...")  // Initial message, will be overwritten
    
    for file in remotes {
        step_number = step_number + 1
        message := "Downloading and moving ${os.base(file[0])}"
        pb.update(step_number, message)
        http.download_file(file[1], os.base(file[1])) or {
            println("Error: Catastrophic error while downloading file ${file[1]}. Check your internet connection")
            exit(1)
        }
        os.mkdir_all(os.dir(os.expand_tilde_to_home(file[0]))) or {
            println("Error while resolving path on ${os.dir(os.expand_tilde_to_home(file[0]))}: ${err}")
            exit(1)
        }
        os.mv(os.base(file[1]), os.expand_tilde_to_home(file[0])) or {
            println("Error while moving to path on ${os.expand_tilde_to_home(file[0])}: ${err}")
            exit(1)
        }
    }
    for file in locals {
        step_number = step_number + 1
        message := "Moving ${os.base(file[0])}..."
        pb.update(step_number, message)
        os.mkdir_all(os.dir(os.expand_tilde_to_home(file[0]))) or {
            println("Error while resolving path on ${os.dir(os.expand_tilde_to_home(file[0]))}: ${err}")
            exit(1)
        }
        os.mv(file[1], os.expand_tilde_to_home(file[0])) or {
            println("Error while moving to path on ${os.expand_tilde_to_home(file[0])}: ${err}")
            exit(1)
        }
    }
    
    pb.finish()
}

// Custom function to parse any line with quoted strings
fn parse_line(line string) []string {
    mut parts := []string{}
    mut current := ''
    mut in_quotes := false
    mut quote_char := ` `

    for i := 0; i < line.len; i++ {
        c := line[i]
        if (c == `"` || c == `'`) && !in_quotes {
            in_quotes = true
            quote_char = c
            continue
        } else if c == quote_char && in_quotes {
            in_quotes = false
            if current != '' {
                parts << current
                current = ''
            }
            continue
        } else if c == ` ` && !in_quotes {
            if current != '' {
                parts << current
                current = ''
            }
            continue
        }
        current += c.ascii_str()
    }
    if current != '' {
        parts << current
    }
    return parts
}