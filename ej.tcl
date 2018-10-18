#!/usr/bin/env wish

# menu  - first example

menubutton .mb1 -text "shape" -menu .mb1.shape
menu .mb1.shape -tearoff 0




.mb1.shape add command -label blob -command { putshape oval }
.mb1.shape add command -label slice -command { putshape arc }
.mb1.shape add command -label square -command { putshape rect }

pack .mb1   -fill both -expand true -side left
