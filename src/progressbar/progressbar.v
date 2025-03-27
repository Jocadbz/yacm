module progressbar

import os

pub struct ProgressBar {
    total int     // Total steps in the task
    width int     // Width of the bar in characters
}

pub fn new(total int, width int) ProgressBar {
    return ProgressBar{
        total: total
        width: width
    }
}

pub fn (p ProgressBar) update(progress int, message string) {
    // Calculate the percentage
    percent := f64(progress) / f64(p.total) * 100
    
    // Calculate how many bar segments to fill
    filled := int(f64(p.width) * (f64(progress) / f64(p.total)))
    
    // Build the progress bar string
    mut bar := "["
    for j in 0 .. p.width {
        if j < filled {
            bar += "#"
        } else {
            bar += " "
        }
    }
    bar += "]"
    
    // Move cursor up one line (if not the first iteration), then print both lines
    if progress > 0 {
        print("\033[1A")  // ANSI escape code to move cursor up 1 line
    }
    // Print message and progress bar, \r to return to start of each line
    print("\r$message\n\r${bar} ${percent:.1f}%")
    os.flush()  // Ensure it displays immediately
}

pub fn (p ProgressBar) finish() {
    println("\nDone!")
}