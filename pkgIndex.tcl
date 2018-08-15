set auto_path [linsert $auto_path 0 /home/elias/Projects/SolventClust/bwidget-1.9.11]
package ifneeded  SolventClust_cb 1.0  [list source [file join $dir main.tcl]]
package ifneeded  SolventClust    1.0  [list source [file join $dir var.tcl]]
