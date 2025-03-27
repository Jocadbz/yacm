module main

import os

fn main() {
	if os.args[1..].len == 0 {
		println("[*] Error - No file provided")
		println("Run with '--help' to display current options")
		exit(1)
	}

	if '--help' in os.args[1..] {
		println("YACM - 2025
Jocadbz - MIT License

Usage: yacm [.]
")
	} else {
		parse_config(os.args[1])
	}
}
