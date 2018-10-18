#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

    # Provoke name search
    catch {package require bogus-package-name}
    set packageNames [package names]

    package require BWidget
    switch $tcl_platform(platform) {
	windows {
	}
	default {
	    option add *ScrolledWindow.size 14
	}
    }
    
    package require Tk
    switch $tcl_platform(platform) {
	windows {
	    option add *Button.padY 0
	}
	default {
	    option add *Scrollbar.width 10
	    option add *Scrollbar.highlightThickness 0
	    option add *Scrollbar.elementBorderWidth 2
	    option add *Scrollbar.borderWidth 2
	}
    }
    
}

#############################################################################
# Visual Tcl v8.6.0.5 Project
#




#############################################################################
## vTcl Code to Load Stock Images


if {![info exist vTcl(sourcing)]} {
#############################################################################
## Procedure:  vTcl:rename

proc ::vTcl:rename {name} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    regsub -all "\\." $name "_" ret
    regsub -all "\\-" $ret "_" ret
    regsub -all " " $ret "_" ret
    regsub -all "/" $ret "__" ret
    regsub -all "::" $ret "__" ret

    return [string tolower $ret]
}

#############################################################################
## Procedure:  vTcl:image:create_new_image

proc ::vTcl:image:create_new_image {filename {description {no description}} {type {}} {data {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    # Does the image already exist?
    if {[info exists ::vTcl(images,files)]} {
        if {[lsearch -exact $::vTcl(images,files) $filename] > -1} { return }
    }

    if {![info exists ::vTcl(sourcing)] && [string length $data] > 0} {
        set object [image create  [vTcl:image:get_creation_type $filename]  -data $data]
    } else {
        # Wait a minute... Does the file actually exist?
        if {! [file exists $filename] } {
            # Try current directory
            set script [file dirname [info script]]
            set filename [file join $script [file tail $filename] ]
        }

        if {![file exists $filename]} {
            set description "file not found!"
            ## will add 'broken image' again when img is fixed, for now create empty
            set object [image create photo -width 1 -height 1]
        } else {
            set object [image create  [vTcl:image:get_creation_type $filename]  -file $filename]
        }
    }

    set reference [vTcl:rename $filename]
    set ::vTcl(images,$reference,image)       $object
    set ::vTcl(images,$reference,description) $description
    set ::vTcl(images,$reference,type)        $type
    set ::vTcl(images,filename,$object)       $filename

    lappend ::vTcl(images,files) $filename
    lappend ::vTcl(images,$type) $object

    # return image name in case caller might want it
    return $object
}

#############################################################################
## Procedure:  vTcl:image:get_image

proc ::vTcl:image:get_image {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    set reference [vTcl:rename $filename]

    # Let's do some checking first
    if {![info exists ::vTcl(images,$reference,image)]} {
        # Well, the path may be wrong; in that case check
        # only the filename instead, without the path.

        set imageTail [file tail $filename]

        foreach oneFile $::vTcl(images,files) {
            if {[file tail $oneFile] == $imageTail} {
                set reference [vTcl:rename $oneFile]
                break
            }
        }
    }
    return $::vTcl(images,$reference,image)
}

#############################################################################
## Procedure:  vTcl:image:get_creation_type

proc ::vTcl:image:get_creation_type {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    switch [string tolower [file extension $filename]] {
        .ppm -
        .jpg -
        .bmp -
        .gif -
	.png	{return photo}
        .xbm    {return bitmap}
        default {return photo}
    }
}

foreach img {


            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

}
#############################################################################
## vTcl Code to Load User Images

catch {package require Img}

foreach img {

        {{[file join / home elias Escritorio watclust_package src logo.gif]} {user image} user {}}

            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

#################################
# VTCL LIBRARY PROCEDURES
#

if {![info exists vTcl(sourcing)]} {
#############################################################################
## Library Procedure:  Window

proc ::Window {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global vTcl
    foreach {cmd name newname} [lrange $args 0 2] {}
    set rest    [lrange $args 3 end]
    if {$name == "" || $cmd == ""} { return }
    if {$newname == ""} { set newname $name }
    if {$name == "."} { wm withdraw $name; return }
    set exists [winfo exists $newname]
    switch $cmd {
	show {
	    if {$exists} {
		wm deiconify $newname
	    } elseif {[info procs vTclWindow$name] != ""} {
		eval "vTclWindow$name $newname $rest"
	    }
	    if {[winfo exists $newname] && [wm state $newname] == "normal"} {
		vTcl:FireEvent $newname <<Show>>
	    }
	}
	hide    {
	    if {$exists} {
		wm withdraw $newname
		vTcl:FireEvent $newname <<Hide>>
		return}
	}
	iconify { if $exists {wm iconify $newname; return} }
	destroy { if $exists {destroy $newname; return} }
    }
}
#############################################################################
## Library Procedure:  ::combobox2::Build

namespace eval ::combobox2 {
proc Build {w args} {
    variable widgetOptions

    if {[winfo exists $w]} {
	error "window name \"$w\" already exists"
    }

    # create the namespace for this instance, and define a few
    # variables
    namespace eval ::combobox2::$w {

	variable ignoreTrace 0
	variable oldFocus    {}
	variable oldGrab     {}
	variable oldValue    {}
	variable options
	variable this
	variable widgets

	set widgets(foo) foo  ;# coerce into an array
	set options(foo) foo  ;# coerce into an array

	unset widgets(foo)
	unset options(foo)
    }

    # import the widgets and options arrays into this proc so
    # we don't have to use fully qualified names, which is a
    # pain.
    upvar ::combobox2::${w}::widgets widgets
    upvar ::combobox2::${w}::options options

    # this is our widget -- a frame of class Combobox2. Naturally,
    # it will contain other widgets. We create it here because
    # we need it to be able to set our default options.
    set widgets(this)   [frame  $w -class Combobox2 -takefocus 0]
    set widgets(entry)  [entry  $w.entry -takefocus 1 -width 8]
    set widgets(button) [label  $w.button -takefocus 0] 

    # this defines all of the default options. We get the
    # values from the option database. Note that if an array
    # value is a list of length one it is an alias to another
    # option, so we just ignore it
    foreach name [array names widgetOptions] {
	if {[llength $widgetOptions($name)] == 1} continue
	set optName  [lindex $widgetOptions($name) 0]
	set optClass [lindex $widgetOptions($name) 1]
	set value [option get $w $optName $optClass]
	set options($name) $value
    }

    # if -value is set to null, we'll remove it from our
    # local array. The assumption is, if the user sets it from
    # the option database, they will set it to something other
    # than null (since it's impossible to determine the difference
    # between a null value and no value at all).
    if {[info exists options(-value)]  && [string length $options(-value)] == 0} {
	unset options(-value)
    }

    # we will later rename the frame's widget proc to be our
    # own custom widget proc. We need to keep track of this
    # new name, so we'll define and store it here...
    set widgets(frame) ::combobox2::${w}::$w

    # gotta do this sooner or later. Might as well do it now
    pack $widgets(entry)  -side left  -fill both -expand yes
    pack $widgets(button) -side right -fill y    -expand no

    # I should probably do this in a catch, but for now it's
    # good enough... What it does, obviously, is put all of
    # the option/values pairs into an array. Make them easier
    # to handle later on...
    array set options $args

    # now, the dropdown list... the same renaming nonsense
    # must go on here as well...
    set widgets(popup)   [toplevel  $w.top]
    set widgets(listbox) [listbox   $w.top.list]
    set widgets(vsb)     [scrollbar $w.top.vsb]

    pack $widgets(listbox) -side left -fill both -expand y

    # fine tune the widgets based on the options (and a few
    # arbitrary values...)

    # NB: we are going to use the frame to handle the relief
    # of the widget as a whole, so the entry widget will be 
    # flat. This makes the button which drops down the list
    # to appear "inside" the entry widget.

    $widgets(vsb) configure  -command "$widgets(listbox) yview"  -highlightthickness 0

    $widgets(button) configure  -highlightthickness 0  -borderwidth 1  -relief raised  -width [expr {[winfo reqwidth $widgets(vsb)] - 2}]

    $widgets(entry) configure  -borderwidth 0  -relief flat  -highlightthickness 0 

    $widgets(popup) configure  -borderwidth 1  -relief sunken

    $widgets(listbox) configure  -selectmode browse  -background [$widgets(entry) cget -bg]  -yscrollcommand "$widgets(vsb) set"  -exportselection false  -borderwidth 0


#    trace variable ::combobox2::${w}::entryTextVariable w  #	    [list ::combobox2::EntryTrace $w]
	
    # do some window management foo on the dropdown window
    wm overrideredirect $widgets(popup) 1
    wm transient        $widgets(popup) [winfo toplevel $w]
    wm group            $widgets(popup) [winfo parent $w]
    wm resizable        $widgets(popup) 0 0
    wm withdraw         $widgets(popup)
    
    # this moves the original frame widget proc into our
    # namespace and gives it a handy name
    rename ::$w $widgets(frame)

    # now, create our widget proc. Obviously (?) it goes in
    # the global namespace. All combobox2 widgets will actually
    # share the same widget proc to cut down on the amount of
    # bloat. 
    proc ::$w {command args}  "eval ::combobox2::WidgetProc $w \$command \$args"


    # ok, the thing exists... let's do a bit more configuration. 
    if {[catch "::combobox2::Configure $widgets(this) [array get options]" error]} {
	catch {destroy $w}
	error $error
    }

    return ""

}
}
#############################################################################
## Library Procedure:  ::combobox2::CallCommand

namespace eval ::combobox2 {
proc CallCommand {w newValue} {
    upvar ::combobox2::${w}::widgets widgets
    upvar ::combobox2::${w}::options options
    
    # call the associated command, if defined and -commandstate is
    # set to "normal"
    if {$options(-commandstate) == "normal" &&  [string length $options(-command)] > 0} {
	set args [list $widgets(this) $newValue]
	uplevel \#0 $options(-command) $args
    }
}
}
#############################################################################
## Library Procedure:  ::combobox2::Canonize

namespace eval ::combobox2 {
proc Canonize {w object opt} {
    variable widgetOptions
    variable columnOptions
    variable widgetCommands
    variable listCommands
    variable scanCommands

    switch $object {
	command {
	    if {[lsearch -exact $widgetCommands $opt] >= 0} {
		return $opt
	    }

	    # command names aren't stored in an array, and there
	    # isn't a way to get all the matches in a list, so
	    # we'll stuff the commands in a temporary array so
	    # we can use [array names]
	    set list $widgetCommands
	    foreach element $list {
		set tmp($element) ""
	    }
	    set matches [array names tmp ${opt}*]
	}

	{list command} {
	    if {[lsearch -exact $listCommands $opt] >= 0} {
		return $opt
	    }

	    # command names aren't stored in an array, and there
	    # isn't a way to get all the matches in a list, so
	    # we'll stuff the commands in a temporary array so
	    # we can use [array names]
	    set list $listCommands
	    foreach element $list {
		set tmp($element) ""
	    }
	    set matches [array names tmp ${opt}*]
	}

	{scan command} {
	    if {[lsearch -exact $scanCommands $opt] >= 0} {
		return $opt
	    }

	    # command names aren't stored in an array, and there
	    # isn't a way to get all the matches in a list, so
	    # we'll stuff the commands in a temporary array so
	    # we can use [array names]
	    set list $scanCommands
	    foreach element $list {
		set tmp($element) ""
	    }
	    set matches [array names tmp ${opt}*]
	}

	option {
	    if {[info exists widgetOptions($opt)]  && [llength $widgetOptions($opt)] == 2} {
		return $opt
	    }
	    set list [array names widgetOptions]
	    set matches [array names widgetOptions ${opt}*]
	}

    }

    if {[llength $matches] == 0} {
	set choices [HumanizeList $list]
	error "unknown $object \"$opt\"; must be one of $choices"

    } elseif {[llength $matches] == 1} {
	set opt [lindex $matches 0]

	# deal with option aliases
	switch $object {
	    option {
		set opt [lindex $matches 0]
		if {[llength $widgetOptions($opt)] == 1} {
		    set opt $widgetOptions($opt)
		}
	    }
	}

	return $opt

    } else {
	set choices [HumanizeList $list]
	error "ambiguous $object \"$opt\"; must be one of $choices"
    }
}
}
#############################################################################
## Library Procedure:  ::combobox2::ComputeGeometry

namespace eval ::combobox2 {
proc ComputeGeometry {w} {
    upvar ::combobox2::${w}::widgets widgets
    upvar ::combobox2::${w}::options options

    if {$options(-height) == 0 && $options(-maxheight) != "0"} {
	# if this is the case, count the items and see if
	# it exceeds our maxheight. If so, set the listbox
	# size to maxheight...
	set nitems [$widgets(listbox) size]
	if {$nitems > $options(-maxheight)} {
	    # tweak the height of the listbox
	    $widgets(listbox) configure -height $options(-maxheight)
	} else {
	    # un-tweak the height of the listbox
	    $widgets(listbox) configure -height 0
	}
	update idletasks
    }

    # compute height and width of the dropdown list
    set bd [$widgets(popup) cget -borderwidth]
    set height [expr {[winfo reqheight $widgets(popup)] + $bd + $bd}]
    set width [winfo width $widgets(this)]

    # figure out where to place it on the screen, trying to take into
    # account we may be running under some virtual window manager
    set screenWidth  [winfo screenwidth $widgets(this)]
    set screenHeight [winfo screenheight $widgets(this)]
    set rootx        [winfo rootx $widgets(this)]
    set rooty        [winfo rooty $widgets(this)]
    set vrootx       [winfo vrootx $widgets(this)]
    set vrooty       [winfo vrooty $widgets(this)]

    # the x coordinate is simply the rootx of our widget, adjusted for
    # the virtual window. We won't worry about whether the window will
    # be offscreen to the left or right -- we want the illusion that it
    # is part of the entry widget, so if part of the entry widget is off-
    # screen, so will the list. If you want to change the behavior,
    # simply change the if statement... (and be sure to update this
    # comment!)
    set x  [expr {$rootx + $vrootx}]
    if {0} { 
	set rightEdge [expr {$x + $width}]
	if {$rightEdge > $screenWidth} {
	    set x [expr {$screenWidth - $width}]
	}
	if {$x < 0} {set x 0}
    }

    # the y coordinate is the rooty plus vrooty offset plus
    # the height of the static part of the widget plus 1 for a 
    # tiny bit of visual separation...
    set y [expr {$rooty + $vrooty + [winfo reqheight $widgets(this)] + 1}]
    set bottomEdge [expr {$y + $height}]

    if {$bottomEdge >= $screenHeight} {
	# ok. Fine. Pop it up above the entry widget isntead of
	# below.
	set y [expr {($rooty - $height - 1) + $vrooty}]

	if {$y < 0} {
	    # this means it extends beyond our screen. How annoying.
	    # Now we'll try to be real clever and either pop it up or
	    # down, depending on which way gives us the biggest list. 
	    # then, we'll trim the list to fit and force the use of
	    # a scrollbar

	    # (sadly, for windows users this measurement doesn't
	    # take into consideration the height of the taskbar,
	    # but don't blame me -- there isn't any way to detect
	    # it or figure out its dimensions. The same probably
	    # applies to any window manager with some magic windows
	    # glued to the top or bottom of the screen)

	    if {$rooty > [expr {$screenHeight / 2}]} {
		# we are in the lower half of the screen -- 
		# pop it up. Y is zero; that parts easy. The height
		# is simply the y coordinate of our widget, minus
		# a pixel for some visual separation. The y coordinate
		# will be the topof the screen.
		set y 1
		set height [expr {$rooty - 1 - $y}]

	    } else {
		# we are in the upper half of the screen --
		# pop it down
		set y [expr {$rooty + $vrooty +  [winfo reqheight $widgets(this)] + 1}]
		set height [expr {$screenHeight - $y}]

	    }

	    # force a scrollbar
	    HandleScrollbar $widgets(this) crop
	}
    }

    if {$y < 0} {
	# hmmm. Bummer.
	set y 0
	set height $screenheight
    }

    set geometry [format "=%dx%d+%d+%d" $width $height $x $y]

    return $geometry
}
}
#############################################################################
## Library Procedure:  ::combobox2::Configure

namespace eval ::combobox2 {
proc Configure {w args} {
    variable widgetOptions
    variable defaultEntryCursor

    upvar ::combobox2::${w}::widgets widgets
    upvar ::combobox2::${w}::options options

    if {[llength $args] == 0} {
	# hmmm. User must be wanting all configuration information
	# note that if the value of an array element is of length
	# one it is an alias, which needs to be handled slightly
	# differently
	set results {}
	foreach opt [lsort [array names widgetOptions]] {
	    if {[llength $widgetOptions($opt)] == 1} {
		set alias $widgetOptions($opt)
		set optName $widgetOptions($alias)
		lappend results [list $opt $optName]
	    } else {
	    	# modif by Christian Gavin 08/02/2000
	    	# if an option has been removed from the list
	    	# (e.g. -value), don't try to access it
	    	if [info exists options($opt)] {
		    set optName  [lindex $widgetOptions($opt) 0]
		    set optClass [lindex $widgetOptions($opt) 1]
		    set default [option get $w $optName $optClass]
		    lappend results [list $opt $optName $optClass  $default $options($opt)]
		}
	    }
	}

	return $results
    }
    
    # one argument means we are looking for configuration
    # information on a single option
    if {[llength $args] == 1} {
	set opt [::combobox2::Canonize $w option [lindex $args 0]]

	set optName  [lindex $widgetOptions($opt) 0]
	set optClass [lindex $widgetOptions($opt) 1]
	set default [option get $w $optName $optClass]
	set results [list $opt $optName $optClass  $default $options($opt)]
	return $results
    }

    # if we have an odd number of values, bail. 
    if {[expr {[llength $args]%2}] == 1} {
	# hmmm. An odd number of elements in args
	error "value for \"[lindex $args end]\" missing"
    }
    
    # Great. An even number of options. Let's make sure they 
    # are all valid before we do anything. Note that Canonize
    # will generate an error if it finds a bogus option; otherwise
    # it returns the canonical option name
    foreach {name value} $args {
	set name [::combobox2::Canonize $w option $name]
	set opts($name) $value
    }

    # process all of the configuration options
    # some (actually, most) options require us to
    # do something, like change the attributes of
    # a widget or two. Here's where we do that...
    foreach option [array names opts] {
	set newValue $opts($option)
	if {[info exists options($option)]} {
	    set oldValue $options($option)
	}

	switch -- $option {
	    -background {
		$widgets(frame)   configure -background $newValue
		$widgets(entry)   configure -background $newValue
		$widgets(listbox) configure -background $newValue
		# let's keep the scrollbar good-looking
		# $widgets(vsb)     configure -background $newValue
		# $widgets(vsb)     configure -troughcolor $newValue
		set options($option) $newValue
	    }

	    -borderwidth {
		$widgets(frame) configure -borderwidth $newValue
		set options($option) $newValue
	    }

	    -command {
		# nothing else to do...
		set options($option) $newValue
	    }

	    -commandstate {
		# do some value checking...
		if {$newValue != "normal" && $newValue != "disabled"} {
		    set options($option) $oldValue
		    set message "bad state value \"$newValue\";"
		    append message " must be normal or disabled"
		    error $message
		}
		set options($option) $newValue
	    }

	    -cursor {
		$widgets(frame) configure -cursor $newValue
		$widgets(entry) configure -cursor $newValue
		$widgets(listbox) configure -cursor $newValue
		set options($option) $newValue
	    }

	    -editable {
		if {$newValue} {
		    # it's editable...
		    $widgets(entry) configure  -state normal  -cursor $defaultEntryCursor
		} else {
		    $widgets(entry) configure  -state disabled  -cursor $options(-cursor)
		}
		set options($option) $newValue
	    }

	    -font {
		$widgets(entry) configure -font $newValue
		$widgets(listbox) configure -font $newValue
		set options($option) $newValue
	    }

	    -foreground {
		$widgets(entry)   configure -foreground $newValue
		$widgets(button)  configure -foreground $newValue
		$widgets(listbox) configure -foreground $newValue
		set options($option) $newValue
	    }

	    -height {
		$widgets(listbox) configure -height $newValue
		HandleScrollbar $w
		set options($option) $newValue
	    }

	    -highlightbackground {
		$widgets(frame) configure -highlightbackground $newValue
		set options($option) $newValue
	    }

	    -highlightcolor {
		$widgets(frame) configure -highlightcolor $newValue
		set options($option) $newValue
	    }

	    -highlightthickness {
		$widgets(frame) configure -highlightthickness $newValue
		set options($option) $newValue
	    }
	    
	    -image {
		if {[string length $newValue] > 0} {
		    $widgets(button) configure -image $newValue
		} else {
		    $widgets(button) configure -image ::combobox2::bimage
		}
		set options($option) $newValue
	    }

	    -maxheight {
		# ComputeGeometry may dork with the actual height
		# of the listbox, so let's undork it
		$widgets(listbox) configure -height $options(-height)
		HandleScrollbar $w
		set options($option) $newValue
	    }

	    -relief {
		$widgets(frame) configure -relief $newValue
		set options($option) $newValue
	    }

	    -selectbackground {
		$widgets(entry) configure -selectbackground $newValue
		$widgets(listbox) configure -selectbackground $newValue
		set options($option) $newValue
	    }

	    -selectborderwidth {
		$widgets(entry) configure -selectborderwidth $newValue
		$widgets(listbox) configure -selectborderwidth $newValue
		set options($option) $newValue
	    }

	    -selectforeground {
		$widgets(entry) configure -selectforeground $newValue
		$widgets(listbox) configure -selectforeground $newValue
		set options($option) $newValue
	    }

	    -state {
		if {$newValue == "normal"} {
		    # it's enabled
		    set editable [::combobox2::GetBoolean  $options(-editable)]
		    if {$editable} {
			$widgets(entry) configure -state normal
			$widgets(entry) configure -takefocus 1
		    }
		} elseif {$newValue == "disabled"}  {
		    # it's disabled
		    $widgets(entry) configure -state disabled
		    $widgets(entry) configure -takefocus 0

		} else {
		    set options($option) $oldValue
		    set message "bad state value \"$newValue\";"
		    append message " must be normal or disabled"
		    error $message
		}

		set options($option) $newValue
	    }

	    -takefocus {
		$widgets(entry) configure -takefocus $newValue
		set options($option) $newValue
	    }

	    -textvariable {
		$widgets(entry) configure -textvariable $newValue
		set options($option) $newValue
	    }

	    -value {
		::combobox2::SetValue $widgets(this) $newValue
		set options($option) $newValue
	    }

	    -width {
        $widgets(frame) configure -width $newValue
		$widgets(listbox) configure -width $newValue
		set options($option) $newValue
	    }

	    -xscrollcommand {
		$widgets(entry) configure -xscrollcommand $newValue
		set options($option) $newValue
	    }

	}
    }
}
}
#############################################################################
## Library Procedure:  ::combobox2::DestroyHandler

namespace eval ::combobox2 {
proc DestroyHandler {w} {

    # If the widget actually being destroyed is of class Combobox2,
    # crush the namespace and kill the proc. Get it? Crush. Kill. 
    # Destroy. Heh. Danger Will Robinson! Oh, man! I'm so funny it
    # brings tears to my eyes.
    if {[string compare [winfo class $w] "Combobox2"] == 0} {
	upvar ::combobox2::${w}::widgets  widgets
	upvar ::combobox2::${w}::options  options

	# delete the namespace and the proc which represents
	# our widget
	namespace delete ::combobox2::$w
	rename ::$w {}
    }   
    return
}
}
#############################################################################
## Library Procedure:  ::combobox2::DoInternalWidgetCommand

namespace eval ::combobox2 {
proc DoInternalWidgetCommand {w subwidget command args} {
    upvar ::combobox2::${w}::widgets widgets
    upvar ::combobox2::${w}::options options

    set subcommand $command
    set command [concat $widgets($subwidget) $command $args]
    if {[catch $command result]} {
	# replace the subwidget name with the megawidget name
	regsub $widgets($subwidget) $result $widgets(this) result

	# replace specific instances of the subwidget command
	# with out megawidget command
	switch $subwidget,$subcommand {
	    listbox,index  {regsub "index"  $result "list index"  result}
	    listbox,insert {regsub "insert" $result "list insert" result}
	    listbox,delete {regsub "delete" $result "list delete" result}
	    listbox,get    {regsub "get"    $result "list get"    result}
	    listbox,size   {regsub "size"   $result "list size"   result}
	}
	error $result

    } else {
	return $result
    }
}
}
#############################################################################
## Library Procedure:  ::combobox2::Find

namespace eval ::combobox2 {
proc Find {w {exact 0}} {
    upvar ::combobox2::${w}::widgets widgets
    upvar ::combobox2::${w}::options options

    ## *sigh* this logic is rather gross and convoluted. Surely
    ## there is a more simple, straight-forward way to implement
    ## all this. As the saying goes, I lack the time to make it
    ## shorter...

    # use what is already in the entry widget as a pattern
    set pattern [$widgets(entry) get]

    if {[string length $pattern] == 0} {
	# clear the current selection
	$widgets(listbox) see 0
	$widgets(listbox) selection clear 0 end
	$widgets(listbox) selection anchor 0
	$widgets(listbox) activate 0
	return
    }

    # we're going to be searching this list...
    set list [$widgets(listbox) get 0 end]

    # if we are doing an exact match, try to find,
    # well, an exact match
    set exactMatch -1
    if {$exact} {
	set exactMatch [lsearch -exact $list $pattern]
    }

    # search for it. We'll try to be clever and not only
    # search for a match for what they typed, but a match for
    # something close to what they typed. We'll keep removing one
    # character at a time from the pattern until we find a match
    # of some sort.
    set index -1
    while {$index == -1 && [string length $pattern]} {
	set index [lsearch -glob $list "$pattern*"]
	if {$index == -1} {
	    regsub {.$} $pattern {} pattern
	}
    }

    # this is the item that most closely matches...
    set thisItem [lindex $list $index]

    # did we find a match? If so, do some additional munging...
    if {$index != -1} {

	# we need to find the part of the first item that is 
	# unique WRT the second... I know there's probably a
	# simpler way to do this... 

	set nextIndex [expr {$index + 1}]
	set nextItem [lindex $list $nextIndex]

	# we don't really need to do much if the next
	# item doesn't match our pattern...
	if {[string match $pattern* $nextItem]} {
	    # ok, the next item matches our pattern, too
	    # now the trick is to find the first character
	    # where they *don't* match...
	    set marker [string length $pattern]
	    while {$marker <= [string length $pattern]} {
		set a [string index $thisItem $marker]
		set b [string index $nextItem $marker]
		if {[string compare $a $b] == 0} {
		    append pattern $a
		    incr marker
		} else {
		    break
		}
	    }
	} else {
	    set marker [string length $pattern]
	}
	
    } else {
	set marker end
	set index 0
    }

    # ok, we know the pattern and what part is unique;
    # update the entry widget and listbox appropriately
    if {$exact && $exactMatch == -1} {
	# this means we didn't find an exact match
	$widgets(listbox) selection clear 0 end
	$widgets(listbox) see $index

    } elseif {!$exact}  {
	# this means we found something, but it isn't an exact
	# match. If we find something that *is* an exact match we
	# don't need to do the following, since it would merely 
	# be replacing the data in the entry widget with itself
	set oldstate [$widgets(entry) cget -state]
	$widgets(entry) configure -state normal
	$widgets(entry) delete 0 end
	$widgets(entry) insert end $thisItem
	$widgets(entry) selection clear
	$widgets(entry) selection range $marker end
	$widgets(listbox) activate $index
	$widgets(listbox) selection clear 0 end
	$widgets(listbox) selection anchor $index
	$widgets(listbox) selection set $index
	$widgets(listbox) see $index
	$widgets(entry) configure -state $oldstate
    }
}
}
#############################################################################
## Library Procedure:  ::combobox2::GetBoolean

namespace eval ::combobox2 {
proc GetBoolean {value {errorValue 1}} {
    if {[catch {expr {([string trim $value])?1:0}} res]} {
	return $errorValue
    } else {
	return $res
    }
}
}
#############################################################################
## Library Procedure:  ::combobox2::HandleEvent

namespace eval ::combobox2 {
proc HandleEvent {w event} {
    upvar ::combobox2::${w}::widgets  widgets
    upvar ::combobox2::${w}::options  options
    upvar ::combobox2::${w}::oldValue oldValue

    # for all of these events, if we have a special action we'll
    # do that and do a "return -code break" to keep additional
    # bindings from firing. Otherwise we'll let the event fall
    # on through.
    switch $event {

	"<Any-KeyPress>" {
	    # if the widget is editable, clear the selection. 
	    # this makes it more obvious what will happen if the 
	    # user presses <Return> (and helps our code know what
	    # to do if the user presses return)
	    if {$options(-editable)} {
		$widgets(listbox) see 0
		$widgets(listbox) selection clear 0 end
		$widgets(listbox) selection anchor 0
		$widgets(listbox) activate 0
	    }
	}

	"<FocusIn>" {
	    set oldValue [$widgets(entry) get]
	}

	"<FocusOut>" {
	    if {![winfo ismapped $widgets(popup)]} {
		# did the value change?
#		set newValue [set ::combobox2::${w}::entryTextVariable]
		set newValue [$widgets(entry) get]
		if {$oldValue != $newValue} {
		    CallCommand $widgets(this) $newValue
		}
	    }
	}

	"<1>" {
	    set editable [::combobox2::GetBoolean $options(-editable)]
	    if {!$editable} {
		if {[winfo ismapped $widgets(popup)]} {
		    $widgets(this) close
		    return -code break;

		} else {
		    if {$options(-state) != "disabled"} {
			$widgets(this) open
			return -code break;
		    }
		}
	    }
	}

	"<Double-1>" {
	    if {$options(-state) != "disabled"} {
		$widgets(this) toggle
		return -code break;
	    }
	}

	"<Tab>" {
	    if {[winfo ismapped $widgets(popup)]} {
		::combobox2::Find $widgets(this) 0
		return -code break;
	    } else {
		::combobox2::SetValue $widgets(this) [$widgets(this) get]
	    }
	}

	"<Escape>" {
#	    $widgets(entry) delete 0 end
#	    $widgets(entry) insert 0 $oldValue
	    if {[winfo ismapped $widgets(popup)]} {
		$widgets(this) close
		return -code break;
	    }
	}

	"<Return>" {
	    # did the value change?
#	    set newValue [set ::combobox2::${w}::entryTextVariable]
	    set newValue [$widgets(entry) get]
	    if {$oldValue != $newValue} {
		CallCommand $widgets(this) $newValue
	    }

	    if {[winfo ismapped $widgets(popup)]} {
		::combobox2::Select $widgets(this)  [$widgets(listbox) curselection]
		return -code break;
	    } 

	}

	"<Next>" {
	    $widgets(listbox) yview scroll 1 pages
	    set index [$widgets(listbox) index @0,0]
	    $widgets(listbox) see $index
	    $widgets(listbox) activate $index
	    $widgets(listbox) selection clear 0 end
	    $widgets(listbox) selection anchor $index
	    $widgets(listbox) selection set $index

	}

	"<Prior>" {
	    $widgets(listbox) yview scroll -1 pages
	    set index [$widgets(listbox) index @0,0]
	    $widgets(listbox) activate $index
	    $widgets(listbox) see $index
	    $widgets(listbox) selection clear 0 end
	    $widgets(listbox) selection anchor $index
	    $widgets(listbox) selection set $index
	}

	"<Down>" {
	    if {[winfo ismapped $widgets(popup)]} {
		tkListboxUpDown $widgets(listbox) 1
		return -code break;

	    } else {
		if {$options(-state) != "disabled"} {
		    $widgets(this) open
		    return -code break;
		}
	    }
	}
	"<Up>" {
	    if {[winfo ismapped $widgets(popup)]} {
		tkListboxUpDown $widgets(listbox) -1
		return -code break;

	    } else {
		if {$options(-state) != "disabled"} {
		    $widgets(this) open
		    return -code break;
		}
	    }
	}
    }

    return ""
}
}
#############################################################################
## Library Procedure:  ::combobox2::HandleScrollbar

namespace eval ::combobox2 {
proc HandleScrollbar {w {action unknown}} {
    upvar ::combobox2::${w}::widgets widgets
    upvar ::combobox2::${w}::options options

    if {$options(-height) == 0} {
	set hlimit $options(-maxheight)
    } else {
	set hlimit $options(-height)
    }

    switch $action {
	"grow" {
	    if {$hlimit > 0 && [$widgets(listbox) size] > $hlimit} {
		pack $widgets(vsb) -side right -fill y -expand n
	    }
	}

	"shrink" {
	    if {$hlimit > 0 && [$widgets(listbox) size] <= $hlimit} {
		pack forget $widgets(vsb)
	    }
	}

	"crop" {
	    # this means the window was cropped and we definitely 
	    # need a scrollbar no matter what the user wants
	    pack $widgets(vsb) -side right -fill y -expand n
	}

	default {
	    if {$hlimit > 0 && [$widgets(listbox) size] > $hlimit} {
		pack $widgets(vsb) -side right -fill y -expand n
	    } else {
		pack forget $widgets(vsb)
	    }
	}
    }

    return ""
}
}
#############################################################################
## Library Procedure:  ::combobox2::HumanizeList

namespace eval ::combobox2 {
proc HumanizeList {list} {

    if {[llength $list] == 1} {
	return [lindex $list 0]
    } else {
	set list [lsort $list]
	set secondToLast [expr {[llength $list] -2}]
	set most [lrange $list 0 $secondToLast]
	set last [lindex $list end]

	return "[join $most {, }] or $last"
    }
}
}
#############################################################################
## Library Procedure:  ::combobox2::Init

namespace eval ::combobox2 {
proc Init {} {
    variable widgetOptions
    variable widgetCommands
    variable scanCommands
    variable listCommands
    variable defaultEntryCursor

    array set widgetOptions [list  -background          {background          Background}  -bd                  -borderwidth  -bg                  -background  -borderwidth         {borderWidth         BorderWidth}  -command             {command             Command}  -commandstate        {commandState        State}  -cursor              {cursor              Cursor}  -editable            {editable            Editable}  -fg                  -foreground  -font                {font                Font}  -foreground          {foreground          Foreground}  -height              {height              Height}  -highlightbackground {highlightBackground HighlightBackground}  -highlightcolor      {highlightColor      HighlightColor}  -highlightthickness  {highlightThickness  HighlightThickness}  -image               {image               Image}  -maxheight           {maxHeight           Height}  -relief              {relief              Relief}  -selectbackground    {selectBackground    Foreground}  -selectborderwidth   {selectBorderWidth   BorderWidth}  -selectforeground    {selectForeground    Background}  -state               {state               State}  -takefocus           {takeFocus           TakeFocus}  -textvariable        {textVariable        Variable}  -value               {value               Value}  -width               {width               Width}  -xscrollcommand      {xScrollCommand      ScrollCommand}  ]


    set widgetCommands [list  bbox      cget     configure    curselection  delete    get      icursor      index         insert    list     scan         selection     xview     select   toggle       open          close  ]

    set listCommands [list  delete       get       index        insert       size  ]

    set scanCommands [list mark dragto]

    # why check for the Tk package? This lets us be sourced into 
    # an interpreter that doesn't have Tk loaded, such as the slave
    # interpreter used by pkg_mkIndex. In theory it should have no
    # side effects when run
    if {[lsearch -exact [package names] "Tk"] != -1} {

	##################################################################
	#- this initializes the option database. Kinda gross, but it works
	#- (I think). 
	##################################################################

	# the image used for the button...
	if {$::tcl_platform(platform) == "windows"} {
	    image create bitmap ::combobox2::bimage -data {
		#define down_arrow_width 12
		#define down_arrow_height 12
		static char down_arrow_bits[] = {
		    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
		    0xfc,0xf1,0xf8,0xf0,0x70,0xf0,0x20,0xf0,
		    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00;
		}
	    }
	} else {
	    image create bitmap ::combobox2::bimage -data  {
		#define down_arrow_width 15
		#define down_arrow_height 15
		static char down_arrow_bits[] = {
		    0x00,0x80,0x00,0x80,0x00,0x80,0x00,0x80,
		    0x00,0x80,0xf8,0x8f,0xf0,0x87,0xe0,0x83,
		    0xc0,0x81,0x80,0x80,0x00,0x80,0x00,0x80,
		    0x00,0x80,0x00,0x80,0x00,0x80
		}
	    }
	}

	# compute a widget name we can use to create a temporary widget
	set tmpWidget ".__tmp__"
	set count 0
	while {[winfo exists $tmpWidget] == 1} {
	    set tmpWidget ".__tmp__$count"
	    incr count
	}

	# get the scrollbar width. Because we try to be clever and draw our
	# own button instead of using a tk widget, we need to know what size
	# button to create. This little hack tells us the width of a scroll
	# bar.
	#
	# NB: we need to be sure and pick a window  that doesn't already
	# exist... 
	scrollbar $tmpWidget
	set sb_width [winfo reqwidth $tmpWidget]
	destroy $tmpWidget

	# steal options from the entry widget
	# we want darn near all options, so we'll go ahead and do
	# them all. No harm done in adding the one or two that we
	# don't use.
	entry $tmpWidget 
	foreach foo [$tmpWidget configure] {
	    # the cursor option is special, so we'll save it in
	    # a special way
	    if {[lindex $foo 0] == "-cursor"} {
		set defaultEntryCursor [lindex $foo 4]
	    }
	    if {[llength $foo] == 5} {
		set option [lindex $foo 1]
		set value [lindex $foo 4]
		option add *Combobox2.$option $value widgetDefault

		# these options also apply to the dropdown listbox
		if {[string compare $option "foreground"] == 0  || [string compare $option "background"] == 0  || [string compare $option "font"] == 0} {
		    option add *Combobox2*ComboboxListbox.$option $value  widgetDefault
		}
	    }
	}
	destroy $tmpWidget

	# these are unique to us...
	option add *Combobox2.cursor              {}
	option add *Combobox2.commandState        normal widgetDefault
	option add *Combobox2.editable            1      widgetDefault
	option add *Combobox2.maxHeight           10     widgetDefault
	option add *Combobox2.height              0
    }

    # set class bindings
    SetClassBindings
}
}
#############################################################################
## Library Procedure:  ::combobox2::Select

namespace eval ::combobox2 {
proc Select {w index} {
    upvar ::combobox2::${w}::widgets widgets
    upvar ::combobox2::${w}::options options

    catch {
	set data [$widgets(listbox) get [lindex $index 0]]
	::combobox2::SetValue $widgets(this) $data

	$widgets(listbox) selection clear 0 end
	$widgets(listbox) selection anchor $index
	$widgets(listbox) selection set $index

	$widgets(entry) selection range 0 end
    }

    $widgets(this) close

    return ""
}
}
#############################################################################
## Library Procedure:  ::combobox2::SetBindings

namespace eval ::combobox2 {
proc SetBindings {w} {
    upvar ::combobox2::${w}::widgets  widgets
    upvar ::combobox2::${w}::options  options

    # juggle the bindtags. The basic idea here is to associate the
    # widget name with the entry widget, so if a user does a bind
    # on the combobox2 it will get handled properly since it is
    # the entry widget that has keyboard focus.
    bindtags $widgets(entry)  [concat $widgets(this) [bindtags $widgets(entry)]]

    bindtags $widgets(button)  [concat $widgets(this) [bindtags $widgets(button)]]

    # override the default bindings for tab and shift-tab. The
    # focus procs take a widget as their only parameter and we
    # want to make sure the right window gets used (for shift-
    # tab we want it to appear as if the event was generated
    # on the frame rather than the entry. I

    bind $widgets(entry) <Tab>  "::combobox2::tkTabToWindow \[tk_focusNext $widgets(entry)\]; break"
    bind $widgets(entry) <Shift-Tab>  "::combobox2::tkTabToWindow \[tk_focusPrev $widgets(this)\]; break"
    
    # this makes our "button" (which is actually a label)
    # do the right thing
    bind $widgets(button) <ButtonPress-1> [list $widgets(this) toggle]

    # this lets the autoscan of the listbox work, even if they
    # move the cursor over the entry widget.
    bind $widgets(entry) <B1-Enter> "break"

    bind $widgets(listbox) <ButtonRelease-1>  "::combobox2::Select $widgets(this) \[$widgets(listbox) nearest %y\]; break"

    bind $widgets(vsb) <ButtonPress-1>   {continue}
    bind $widgets(vsb) <ButtonRelease-1> {continue}

    bind $widgets(listbox) <Any-Motion> {
	%W selection clear 0 end
	%W activate @%x,%y
	%W selection anchor @%x,%y
	%W selection set @%x,%y @%x,%y
	# need to do a yview if the cursor goes off the top
	# or bottom of the window... (or do we?)
    }

    # these events need to be passed from the entry
    # widget to the listbox, or need some sort of special
    # handling....
    foreach event [list <Up> <Down> <Tab> <Return> <Escape>  <Next> <Prior> <Double-1> <1> <Any-KeyPress>  <FocusIn> <FocusOut>] {
	bind $widgets(entry) $event  "::combobox2::HandleEvent $widgets(this) $event"
    }

}
}
#############################################################################
## Library Procedure:  ::combobox2::SetClassBindings

namespace eval ::combobox2 {
proc SetClassBindings {} {

    # make sure we clean up after ourselves...
    bind Combobox2 <Destroy> [list ::combobox2::DestroyHandler %W]

    # this will (hopefully) close (and lose the grab on) the
    # listbox if the user clicks anywhere outside of it. Note
    # that on Windows, you can click on some other app and
    # the listbox will still be there, because tcl won't see
    # that button click
    set this {[::combobox2::convert %W -W]}
    bind Combobox2 <Any-ButtonPress>   "$this close"
    bind Combobox2 <Any-ButtonRelease> "$this close"

    # this helps (but doesn't fully solve) focus issues. The general
    # idea is, whenever the frame gets focus it gets passed on to
    # the entry widget
    bind Combobox2 <FocusIn> {::combobox2::tkTabToWindow [::combobox2::convert %W -W].entry}

    # this closes the listbox if we get hidden
    bind Combobox2 <Unmap> {[::combobox2::convert %W -W] close}

    return ""
}
}
#############################################################################
## Library Procedure:  ::combobox2::SetValue

namespace eval ::combobox2 {
proc SetValue {w newValue} {

    upvar ::combobox2::${w}::widgets     widgets
    upvar ::combobox2::${w}::options     options
    upvar ::combobox2::${w}::ignoreTrace ignoreTrace
    upvar ::combobox2::${w}::oldValue    oldValue

    if {[info exists options(-textvariable)]  && [string length $options(-textvariable)] > 0} {
	set variable ::$options(-textvariable)
	set $variable $newValue
    } else {
	set oldstate [$widgets(entry) cget -state]
	$widgets(entry) configure -state normal
	$widgets(entry) delete 0 end
	$widgets(entry) insert 0 $newValue
	$widgets(entry) configure -state $oldstate
    }

    # set our internal textvariable; this will cause any public
    # textvariable (ie: defined by the user) to be updated as
    # well
#    set ::combobox2::${w}::entryTextVariable $newValue

    # redefine our concept of the "old value". Do it before running
    # any associated command so we can be sure it happens even
    # if the command somehow fails.
    set oldValue $newValue


    # call the associated command. The proc will handle whether or 
    # not to actually call it, and with what args
    CallCommand $w $newValue

    return ""
}
}
#############################################################################
## Library Procedure:  ::combobox2::VTrace

namespace eval ::combobox2 {
proc VTrace {w args} {
    upvar ::combobox2::${w}::widgets widgets
    upvar ::combobox2::${w}::options options
    upvar ::combobox2::${w}::ignoreTrace ignoreTrace

    if {[info exists ignoreTrace]} return
    ::combobox2::SetValue $widgets(this) [set ::$options(-textvariable)]

    return ""
}
}
#############################################################################
## Library Procedure:  ::combobox2::WidgetProc

namespace eval ::combobox2 {
proc WidgetProc {w command args} {
    upvar ::combobox2::${w}::widgets widgets
    upvar ::combobox2::${w}::options options
    upvar ::combobox2::${w}::oldFocus oldFocus
    upvar ::combobox2::${w}::oldFocus oldGrab

    set command [::combobox2::Canonize $w command $command]

    # this is just shorthand notation...
    set doWidgetCommand  [list ::combobox2::DoInternalWidgetCommand $widgets(this)]

    if {$command == "list"} {
	# ok, the next argument is a list command; we'll 
	# rip it from args and append it to command to
	# create a unique internal command
	#
	# NB: because of the sloppy way we are doing this,
	# we'll also let the user enter our secret command
	# directly (eg: listinsert, listdelete), but we
	# won't document that fact
	set command "list-[lindex $args 0]"
	set args [lrange $args 1 end]
    }

    set result ""

    # many of these commands are just synonyms for specific
    # commands in one of the subwidgets. We'll get them out
    # of the way first, then do the custom commands.
    switch $command {
	bbox -
	delete -
	get -
	icursor -
	index -
	insert -
	scan -
	selection -
	xview {
	    set result [eval $doWidgetCommand entry $command $args]
	}
	list-get 	{set result [eval $doWidgetCommand listbox get $args]}
	list-index 	{set result [eval $doWidgetCommand listbox index $args]}
	list-size 	{set result [eval $doWidgetCommand listbox size $args]}

	select {
	    if {[llength $args] == 1} {
		set index [lindex $args 0]
		set result [Select $widgets(this) $index]
	    } else {
		error "usage: $w select index"
	    }
	}

	subwidget {
	    set knownWidgets [list button entry listbox popup vsb]
	    if {[llength $args] == 0} {
		return $knownWidgets
	    }

	    set name [lindex $args 0]
	    if {[lsearch $knownWidgets $name] != -1} {
		set result $widgets($name)
	    } else {
		error "unknown subwidget $name"
	    }
	}

	curselection {
	    set result [eval $doWidgetCommand listbox curselection]
	}

	list-insert {
	    eval $doWidgetCommand listbox insert $args
	    set result [HandleScrollbar $w "grow"]
	}

	list-delete {
	    eval $doWidgetCommand listbox delete $args
	    set result [HandleScrollbar $w "shrink"]
	}

	toggle {
	    # ignore this command if the widget is disabled...
	    if {$options(-state) == "disabled"} return

	    # pops down the list if it is not, hides it
	    # if it is...
	    if {[winfo ismapped $widgets(popup)]} {
		set result [$widgets(this) close]
	    } else {
		set result [$widgets(this) open]
	    }
	}

	open {

	    # if this is an editable combobox2, the focus should
	    # be set to the entry widget
	    if {$options(-editable)} {
		focus $widgets(entry)
		$widgets(entry) select range 0 end
		$widgets(entry) icur end
	    }

	    # if we are disabled, we won't allow this to happen
	    if {$options(-state) == "disabled"} {
		return 0
	    }

	    # compute the geometry of the window to pop up, and set
	    # it, and force the window manager to take notice
	    # (even if it is not presently visible).
	    #
	    # this isn't strictly necessary if the window is already
	    # mapped, but we'll go ahead and set the geometry here
	    # since its harmless and *may* actually reset the geometry
	    # to something better in some weird case.
	    set geometry [::combobox2::ComputeGeometry $widgets(this)]
	    wm geometry $widgets(popup) $geometry
	    update idletasks

	    # if we are already open, there's nothing else to do
	    if {[winfo ismapped $widgets(popup)]} {
		return 0
	    }

	    # save the widget that currently has the focus; we'll restore
	    # the focus there when we're done
	    set oldFocus [focus]

	    # ok, tweak the visual appearance of things and 
	    # make the list pop up
	    $widgets(button) configure -relief sunken
	    raise $widgets(popup) [winfo parent $widgets(this)]
	    wm deiconify $widgets(popup)

	    # force focus to the entry widget so we can handle keypress
	    # events for traversal
	    focus -force $widgets(entry)

	    # select something by default, but only if its an
	    # exact match...
	    ::combobox2::Find $widgets(this) 1

	    # save the current grab state for the display containing
	    # this widget. We'll restore it when we close the dropdown
	    # list
	    set status "none"
	    set grab [grab current $widgets(this)]
	    if {$grab != ""} {set status [grab status $grab]}
	    set oldGrab [list $grab $status]
	    unset grab status

	    # *gasp* do a global grab!!! Mom always told not to
	    # do things like this, but these are desparate times.
	    grab -global $widgets(this)

	    # fake the listbox into thinking it has focus. This is 
	    # necessary to get scanning initialized properly in the
	    # listbox.
	    event generate $widgets(listbox) <B1-Enter>

	    return 1
	}

	close {
	    # if we are already closed, don't do anything...
	    if {![winfo ismapped $widgets(popup)]} {
		return 0
	    }

	    # restore the focus and grab, but ignore any errors...
	    # we're going to be paranoid and release the grab before
	    # trying to set any other grab because we really really
	    # really want to make sure the grab is released.
	    catch {focus $oldFocus} result
	    catch {grab release $widgets(this)}
	    catch {
		set status [lindex $oldGrab 1]
		if {$status == "global"} {
		    grab -global [lindex $oldGrab 0]
		} elseif {$status == "local"} {
		    grab [lindex $oldGrab 0]
		}
		unset status
	    }

	    # hides the listbox
	    $widgets(button) configure -relief raised
	    wm withdraw $widgets(popup) 

	    # select the data in the entry widget. Not sure
	    # why, other than observation seems to suggest that's
	    # what windows widgets do.
	    set editable [::combobox2::GetBoolean $options(-editable)]
	    if {$editable} {
		$widgets(entry) selection range 0 end
		$widgets(button) configure -relief raised
	    }


	    # magic tcl stuff (see tk.tcl in the distribution 
	    # lib directory)
	    tkCancelRepeat

	    return 1
	}

	cget {
	    if {[llength $args] != 1} {
		error "wrong # args: should be $w cget option"
	    }
	    set opt [::combobox2::Canonize $w option [lindex $args 0]]

	    if {$opt == "-value"} {
		set result [$widget(entry) get]
	    } else {
		set result $options($opt)
	    }
	}

	configure {
	    set result [eval ::combobox2::Configure {$w} $args]
	}

	default {
	    error "bad option \"$command\""
	}
    }

    return $result
}
}
#############################################################################
## Library Procedure:  ::combobox2::combobox2

namespace eval ::combobox2 {
proc combobox2 {w args} {
    variable widgetOptions
    variable widgetCommands
    variable scanCommands
    variable listCommands

    # perform a one time initialization
    if {![info exists widgetOptions]} {
	__combobox2_Setup
        Init
    }

    # build it...
    eval Build $w $args

    # set some bindings...
    SetBindings $w

    # and we are done!
    return $w
}
}
#############################################################################
## Library Procedure:  ::combobox2::convert

namespace eval ::combobox2 {
proc convert {w args} {
    set result {}
    if {![winfo exists $w]} {
	error "window \"$w\" doesn't exist"
    }

    while {[llength $args] > 0} {
	set option [lindex $args 0]
	set args [lrange $args 1 end]

	switch -exact -- $option {
	    -x {
		set value [lindex $args 0]
		set args [lrange $args 1 end]
		set win $w
		while {[winfo class $win] != "Combobox2"} {
		    incr value [winfo x $win]
		    set win [winfo parent $win]
		    if {$win == "."} break
		}
		lappend result $value
	    }

	    -y {
		set value [lindex $args 0]
		set args [lrange $args 1 end]
		set win $w
		while {[winfo class $win] != "Combobox2"} {
		    incr value [winfo y $win]
		    set win [winfo parent $win]
		    if {$win == "."} break
		}
		lappend result $value
	    }

	    -w -
	    -W {
		set win $w
		while {[winfo class $win] != "Combobox2"} {
		    set win [winfo parent $win]
		    if {$win == "."} break;
		}
		lappend result $win
	    }
	}
    }
    return $result
}
}
#############################################################################
## Library Procedure:  ::combobox2::tkCancelRepeat

namespace eval ::combobox2 {
proc tkCancelRepeat {} {
    global tk_version
    if {$tk_version >= 8.4} {
        ::tk::CancelRepeat
    } else {
        ::tkCancelRepeat
    }
}
}
#############################################################################
## Library Procedure:  ::combobox2::tkTabToWindow

namespace eval ::combobox2 {
proc tkTabToWindow {w} {
    global tk_version
    if {$tk_version >= 8.4} {
        ::tk::TabToWindow $w
    } else {
        ::tkTabToWindow $w
    }
}
}
#############################################################################
## Library Procedure:  ::vTcl::widgets::bwidgets::scrollchildsite::widgetProc

namespace eval ::vTcl::widgets::bwidgets::scrollchildsite {
proc widgetProc {w args} {
        set command [lindex $args 0]
        set args [lrange $args 1 end]
        set children [winfo children $w]
        set child [lindex $children 0]

        ## we have renamed the default widgetProc _<widgetpath>
        if {$command == "configure" && $args == ""} {
            if {$children == ""} {
                return [concat [uplevel _$w configure]  [list {-xscrollcommand xScrollCommand ScrollCommand {} {}}]  [list {-yscrollcommand yScrollCommand ScrollCommand {} {}}]]
            } else {
                return [concat [uplevel _$w configure]  [list [$child configure -xscrollcommand]]  [list [$child configure -yscrollcommand]]]
            }
        } elseif {$command == "configure" && [llength $args] > 1} {
            return [uplevel $child configure $args]
        } elseif {[string match ?view $command]} {
            return [uplevel $child $command $args]
        }

        uplevel _$w $command $args
    }
}
#############################################################################
## Library Procedure:  __combobox2_Setup

proc ::__combobox2_Setup {} {

    namespace eval ::combobox2 {

        # this is the public interface
        namespace export combobox2

        # these contain references to available options
        variable widgetOptions

        # these contain references to available commands and subcommands
        variable widgetCommands
        variable scanCommands
        variable listCommands
    }
}
#############################################################################
## Library Procedure:  vTcl::widgets::bwidgets::scrolledwindow::createCmd

namespace eval vTcl::widgets::bwidgets::scrolledwindow {
proc createCmd {target args} {
        eval ScrolledWindow $target $args
        ## create a frame where user can insert widget to scroll
        frame $target.f -class ScrollChildsite

        ## change the widget procedure
        rename ::$target.f ::_$target.f
        proc ::$target.f {command args}  "eval ::vTcl::widgets::bwidgets::scrollchildsite::widgetProc $target.f \$command \$args"
    }
}
#############################################################################
## Library Procedure:  vTcl:DefineAlias

proc ::vTcl:DefineAlias {target alias widgetProc top_or_alias cmdalias} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global widget
    set widget($alias) $target
    set widget(rev,$target) $alias
    if {$cmdalias} {
	interp alias {} $alias {} $widgetProc $target
    }
    if {$top_or_alias != ""} {
	set widget($top_or_alias,$alias) $target
	if {$cmdalias} {
	    interp alias {} $top_or_alias.$alias {} $widgetProc $target
	}
    }
}
#############################################################################
## Library Procedure:  vTcl:DoCmdOption

proc ::vTcl:DoCmdOption {target cmd} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## menus are considered toplevel windows
    set parent $target
    while {[winfo class $parent] == "Menu"} {
        set parent [winfo parent $parent]
    }

    regsub -all {\%widget} $cmd $target cmd
    regsub -all {\%top} $cmd [winfo toplevel $parent] cmd

    uplevel #0 [list eval $cmd]
}
#############################################################################
## Library Procedure:  vTcl:FireEvent

proc ::vTcl:FireEvent {target event {params {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## The window may have disappeared
    if {![winfo exists $target]} return
    ## Process each binding tag, looking for the event
    foreach bindtag [bindtags $target] {
	set tag_events [bind $bindtag]
	set stop_processing 0
	foreach tag_event $tag_events {
	    if {$tag_event == $event} {
		set bind_code [bind $bindtag $tag_event]
		foreach rep "\{%W $target\} $params" {
		    regsub -all [lindex $rep 0] $bind_code [lindex $rep 1] bind_code
		}
		set result [catch {uplevel #0 $bind_code} errortext]
		if {$result == 3} {
		    ## break exception, stop processing
		    set stop_processing 1
		} elseif {$result != 0} {
		    bgerror $errortext
		}
		break
	    }
	}
	if {$stop_processing} {break}
    }
}
#############################################################################
## Library Procedure:  vTcl:Toplevel:WidgetProc

proc ::vTcl:Toplevel:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }
    set command [lindex $args 0]
    set args [lrange $args 1 end]
    switch -- [string tolower $command] {
        "setvar" {
            foreach {varname value} $args {}
            if {$value == ""} {
                return [set ::${w}::${varname}]
            } else {
                return [set ::${w}::${varname} $value]
            }
        }
        "hide" - "show" {
            Window [string tolower $command] $w
        }
        "showmodal" {
            ## modal dialog ends when window is destroyed
            Window show $w; raise $w
            grab $w; tkwait window $w; grab release $w
        }
        "startmodal" {
            ## ends when endmodal called
            Window show $w; raise $w
            set ::${w}::_modal 1
            grab $w; tkwait variable ::${w}::_modal; grab release $w
        }
        "endmodal" {
            ## ends modal dialog started with startmodal, argument is var name
            set ::${w}::_modal 0
            Window hide $w
        }
        default {
            uplevel $w $command $args
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:WidgetProc

proc ::vTcl:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
	## If no arguments, returns the path the alias points to
	return $w
    }

    set command [lindex $args 0]
    set args [lrange $args 1 end]
    uplevel $w $command $args
}
#############################################################################
## Library Procedure:  vTcl:toplevel

proc ::vTcl:toplevel {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    uplevel #0 eval toplevel $args
    set target [lindex $args 0]
    namespace eval ::$target {set _modal 0}
}
}


if {[info exists vTcl(sourcing)]} {

proc vTcl:project:info {} {
    set base .top44
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    set site_4_0 [$base.not45 getframe page1]
    set site_4_0 $site_4_0
    set site_5_0 $site_4_0.fra92
    set site_6_0 $site_5_0.fra98
    set site_6_0 $site_5_0.fra50
    set site_6_0 $site_5_0.cpd55
    set site_4_1 [$base.not45 getframe page2]
    set site_4_0 $site_4_1
    set site_5_0 $site_4_0.cpd46
    set site_5_0 $site_4_0.cpd47
    set site_4_2 [$base.not45 getframe page3]
    set site_4_0 $site_4_2
    set site_5_0 $site_4_0.fra52
    set site_4_3 [$base.not45 getframe page4]
    set site_3_0 $base.cpd47
    namespace eval ::widgets_bindings {
        set tagslist _TopLevel
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            load_all
            main
            toggleDisabled
            activate_frame
            load_solvents
        }
        set compounds {
        }
        set projectType single
    }
}
}

#################################
# USER DEFINED PROCEDURES
#
#############################################################################
## Procedure:  load_all

proc ::load_all {} {
# Import All packages.
package ifneeded  SolventClust    1.0  [list source  var.tcl]
package require SolventClust
#Launch main window
proc SolventClust_tk_cb {} {
Window show .
Window show .top44
}
}
#############################################################################
## Procedure:  main

proc ::main {argv argc} {
# Import All packages.
package ifneeded  SolventClust    1.0  [list source  var.tcl]
package require SolventClust
#Launch main window
proc SolventClust_tk_cb {} {
Window show .
Window show .top44
}
load_solvents $::SolventClust::solvents_array densitylist menudensity
}
#############################################################################
## Procedure:  toggleDisabled

proc ::toggleDisabled {state wtop disabledfg} {
if { [winfo class $wtop] == "Frame" } { 
        set children [winfo children $wtop] 
    } { 
        set children $wtop 
    }
    foreach w $children { 
        if { [ winfo class $w ] == "Frame" } { 
            toggleDisabled $state $w $disabledfg 
            continue 
        } 
        if { [ lsearch -exact "Entry Label Message" [ winfo class $w ]] >= 0 } { 
            if { $state == "disabled" } { 
                $w config -foreground $disabledfg 
            } { 
                $w config -foreground black 
            } 
        } 
        if { [ lsearch -exact "Button Checkbutton Entry Radiobutton Menubutton" [ winfo class $w ]] >= 0 } { 
            if { $state == "disabled" } { 
                $w config -state disabled 
            } { 
                if { [$w cget -background] != "green" } { 
                    $w config -state normal 
                } 
            } 
        } 
    } 
}
#############################################################################
## Procedure:  activate_frame

proc ::activate_frame {buttonexample objecttomodify varstate} {
#set disablecolour from texentry
set disabledcolour [$::widget($buttonexample) cget -disabledforeground]
if { [string is false -strict $varstate] } {
    toggleDisabled normal   $::widget($objecttomodify)    $disabledcolour
} else {
    toggleDisabled disabled $::widget($objecttomodify)    $disabledcolour 
}
    
}
#############################################################################
## Procedure:  load_solvents

proc ::load_solvents {solvents_array menubuttonobject menubuttonparent} {
global widget
foreach solvent $solvents_array {
    set solvent_label   [lindex $solvent 0]
    set solvent_density [lindex $solvent 1]
    $widget($menubuttonobject) add radiobutton -variable solventtype -value $solvent_density -label "${solvent_label} - ${solvent_density}" -command {set ::SolventClust::density $solventtype}
}
}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {
global widget
load_all
}

init $argc $argv

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    wm focusmodel $top passive
    wm geometry $top 1x1+0+0; update
    wm maxsize $top 1351 738
    wm minsize $top 1 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm withdraw $top
    wm title $top "vtcl.tcl"
    bindtags $top "$top Vtcl.tcl all"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    ###################
    # SETTING GEOMETRY
    ###################

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top44 {base} {
    if {$base == ""} {
        set base .top44
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
		-menu "$top.m47" -highlightcolor black 
    wm focusmodel $top passive
    wm geometry $top 678x604+393+69; update
    wm maxsize $top 1351 738
    wm minsize $top 1 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm deiconify $top
    wm title $top "SolventClust"
    vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    NoteBook $top.not45 \
		-font {Helvetica 12} -height 429 -width 659 
    vTcl:DefineAlias "$top.not45" "Notebook1" vTcl:WidgetProc "Toplevel1" 1
    bind $top.not45 <Button-1> {
        # TODO: your event handler here
    }
    $top.not45 insert end page1 \
		-activebackground {#f9f9f9} -activeforeground black \
		-background {#d9d9d9} -disabledforeground {#a3a3a3} -foreground black \
		-text {Molecule Selection} 
    $top.not45 insert end page2 \
		-activebackground {#f9f9f9} -activeforeground black \
		-background {#d9d9d9} -disabledforeground {#a3a3a3} -foreground black \
		-text {Probe Settings} 
    $top.not45 insert end page3 \
		-activebackground {#f9f9f9} -activeforeground black \
		-background {#d9d9d9} -disabledforeground {#a3a3a3} -foreground black \
		-text Compute 
    $top.not45 insert end page4 \
		-activebackground {#f9f9f9} -activeforeground black \
		-background {#d9d9d9} -disabledforeground {#a3a3a3} -foreground black \
		-text Save 
    set site_4_0 [$top.not45 getframe page1]
    frame $site_4_0.fra92 \
		-borderwidth 2 -relief groove -height 330 -highlightcolor black \
		-width 645 
    vTcl:DefineAlias "$site_4_0.fra92" "Frame4" vTcl:WidgetProc "Toplevel1" 1
    set site_5_0 $site_4_0.fra92
    frame $site_5_0.fra98 \
		-borderwidth 2 -relief groove -height 75 -highlightcolor black \
		-width 620 
    vTcl:DefineAlias "$site_5_0.fra98" "Frame1" vTcl:WidgetProc "Toplevel1" 1
    set site_6_0 $site_5_0.fra98
    entry $site_6_0.ent102 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable ::SolventClust::selstring1 
    vTcl:DefineAlias "$site_6_0.ent102" "Entry1" vTcl:WidgetProc "Toplevel1" 1
    label $site_6_0.lab104 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text Selection 
    vTcl:DefineAlias "$site_6_0.lab104" "Label6" vTcl:WidgetProc "Toplevel1" 1
    label $site_6_0.lab109 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Select Molecule} 
    vTcl:DefineAlias "$site_6_0.lab109" "Label8" vTcl:WidgetProc "Toplevel1" 1
    menubutton $site_6_0.men115 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -menu "$site_6_0.men115.m" -padx 5 -pady 4 \
		-text menu 
    vTcl:DefineAlias "$site_6_0.men115" "moleculemenu" vTcl:WidgetProc "Toplevel1" 1
    menu $site_6_0.men115.m \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-tearoff 0 
    label $site_6_0.lab44 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Frame  First:} 
    vTcl:DefineAlias "$site_6_0.lab44" "Label3" vTcl:WidgetProc "Toplevel1" 1
    entry $site_6_0.ent45 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable ::SolventClust::first 
    vTcl:DefineAlias "$site_6_0.ent45" "Entry2" vTcl:WidgetProc "Toplevel1" 1
    label $site_6_0.lab46 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text Last: 
    vTcl:DefineAlias "$site_6_0.lab46" "Label9" vTcl:WidgetProc "Toplevel1" 1
    entry $site_6_0.ent48 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable ::SolventClust::last 
    vTcl:DefineAlias "$site_6_0.ent48" "Entry3" vTcl:WidgetProc "Toplevel1" 1
    label $site_6_0.lab49 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text step 
    vTcl:DefineAlias "$site_6_0.lab49" "Label10" vTcl:WidgetProc "Toplevel1" 1
    entry $site_6_0.ent50 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable ::SolventClust::step 
    vTcl:DefineAlias "$site_6_0.ent50" "Entry4" vTcl:WidgetProc "Toplevel1" 1
    place $site_6_0.ent102 \
		-in $site_6_0 -x 25 -y 36 -width 241 -height 25 -anchor nw \
		-bordermode ignore 
    place $site_6_0.lab104 \
		-in $site_6_0 -x 116 -y 17 -width 59 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_6_0.lab109 \
		-in $site_6_0 -x 413 -y 1 -width 97 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_6_0.men115 \
		-in $site_6_0 -x 335 -y 18 -width 247 -height 24 -anchor nw \
		-bordermode ignore 
    place $site_6_0.lab44 \
		-in $site_6_0 -x 285 -y 52 -width 80 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_6_0.ent45 \
		-in $site_6_0 -x 368 -y 47 -width 40 -height 23 -anchor nw \
		-bordermode ignore 
    place $site_6_0.lab46 \
		-in $site_6_0 -x 410 -y 52 -width 33 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_6_0.ent48 \
		-in $site_6_0 -x 451 -y 47 -width 40 -height 23 -anchor nw \
		-bordermode ignore 
    place $site_6_0.lab49 \
		-in $site_6_0 -x 495 -y 51 -width 42 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_6_0.ent50 \
		-in $site_6_0 -x 534 -y 47 -width 40 -height 23 -anchor nw \
		-bordermode ignore 
    label $site_5_0.lab100 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Use Molecule:} 
    vTcl:DefineAlias "$site_5_0.lab100" "Label4" vTcl:WidgetProc "Toplevel1" 1
    frame $site_5_0.fra50 \
		-borderwidth 2 -relief groove -height 95 -highlightcolor black \
		-width 620 
    vTcl:DefineAlias "$site_5_0.fra50" "FrameReference" vTcl:WidgetProc "Toplevel1" 1
    set site_6_0 $site_5_0.fra50
    entry $site_6_0.ent59 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable ::SolventClust::selstring2 
    vTcl:DefineAlias "$site_6_0.ent59" "EntryReference" vTcl:WidgetProc "Toplevel1" 1
    label $site_6_0.lab60 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text Selection 
    vTcl:DefineAlias "$site_6_0.lab60" "Label5" vTcl:WidgetProc "Toplevel1" 1
    menubutton $site_6_0.men44 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -menu "$site_6_0.men44.m" -padx 5 -pady 4 \
		-text menu 
    vTcl:DefineAlias "$site_6_0.men44" "referencemenu" vTcl:WidgetProc "Toplevel1" 1
    menu $site_6_0.men44.m \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-tearoff 0 
    label $site_6_0.cpd45 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Select Molecule} 
    vTcl:DefineAlias "$site_6_0.cpd45" "Label14" vTcl:WidgetProc "Toplevel1" 1
    place $site_6_0.ent59 \
		-in $site_6_0 -x 30 -y 35 -width 236 -height 30 -anchor nw \
		-bordermode ignore 
    place $site_6_0.lab60 \
		-in $site_6_0 -x 117 -y 17 -width 59 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_6_0.men44 \
		-in $site_6_0 -x 320 -y 40 -width 147 -height 24 -anchor nw \
		-bordermode ignore 
    place $site_6_0.cpd45 \
		-in $site_6_0 -x 345 -y 20 -anchor nw -bordermode inside 
    frame $site_5_0.cpd55 \
		-borderwidth 2 -relief groove -height 95 -highlightcolor black \
		-width 620 
    vTcl:DefineAlias "$site_5_0.cpd55" "FrameGrid" vTcl:WidgetProc "Toplevel1" 1
    set site_6_0 $site_5_0.cpd55
    menubutton $site_6_0.men61 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -menu "$site_6_0.men61.m" -padx 5 -pady 4 \
		-state disabled -text menu 
    vTcl:DefineAlias "$site_6_0.men61" "Menubutton5" vTcl:WidgetProc "Toplevel1" 1
    menu $site_6_0.men61.m \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-tearoff 0 
    label $site_6_0.lab62 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Use grid:} 
    vTcl:DefineAlias "$site_6_0.lab62" "Label7" vTcl:WidgetProc "Toplevel1" 1
    place $site_6_0.men61 \
		-in $site_6_0 -x 185 -y 29 -width 202 -height 29 -anchor nw \
		-bordermode ignore 
    place $site_6_0.lab62 \
		-in $site_6_0 -x 255 -y 10 -anchor nw -bordermode ignore 
    radiobutton $site_5_0.rad56 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {activate_frame Button1 FrameReference False
activate_frame Button1 FrameGrid      True} \
		-foreground black -highlightcolor black -text {Reference Molecule} \
		-value False -variable ::SolventClust::grid 
    vTcl:DefineAlias "$site_5_0.rad56" "fitmolradiobutton" vTcl:WidgetProc "Toplevel1" 1
    radiobutton $site_5_0.cpd57 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {activate_frame Button1 FrameReference True
activate_frame Button1 FrameGrid      False} \
		-foreground black -highlightcolor black -text {Grid Map} -value True \
		-variable ::SolventClust::grid 
    vTcl:DefineAlias "$site_5_0.cpd57" "fitgridradiobutton" vTcl:WidgetProc "Toplevel1" 1
    place $site_5_0.fra98 \
		-in $site_5_0 -x 11 -y 19 -width 620 -height 75 -anchor nw \
		-bordermode ignore 
    place $site_5_0.lab100 \
		-in $site_5_0 -x 260 -y 11 -width 86 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_5_0.fra50 \
		-in $site_5_0 -x 11 -y 114 -width 620 -height 95 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd55 \
		-in $site_5_0 -x 12 -y 228 -width 620 -height 95 -anchor nw \
		-bordermode ignore 
    place $site_5_0.rad56 \
		-in $site_5_0 -x 10 -y 94 -width 143 -height 20 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd57 \
		-in $site_5_0 -x 10 -y 208 -width 82 -height 20 -anchor nw \
		-bordermode ignore 
    label $site_4_0.lab95 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Fitting Options} 
    vTcl:DefineAlias "$site_4_0.lab95" "Label1" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but114 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {#.top44.not45 getframe .top44.not45.cpd99
puts $::SolventClust::molecules} \
		-foreground black -highlightcolor black -text Next 
    vTcl:DefineAlias "$site_4_0.but114" "Button1" vTcl:WidgetProc "Toplevel1" 1
    place $site_4_0.fra92 \
		-in $site_4_0 -x 4 -y 20 -width 645 -height 330 -anchor nw \
		-bordermode ignore 
    place $site_4_0.lab95 \
		-in $site_4_0 -x 20 -y 10 -anchor nw -bordermode ignore 
    place $site_4_0.but114 \
		-in $site_4_0 -x 570 -y 360 -width 69 -height 26 -anchor nw \
		-bordermode ignore 
    set site_4_1 [$top.not45 getframe page2]
    frame $site_4_1.cpd46 \
		-borderwidth 2 -relief groove -height 60 -highlightcolor black \
		-width 645 
    vTcl:DefineAlias "$site_4_1.cpd46" "Frame9" vTcl:WidgetProc "Toplevel1" 1
    set site_5_0 $site_4_1.cpd46
    radiobutton $site_5_0.rad68 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {activate_frame Button1 menudensity False
activate_frame Button1 Entrydensity     True} \
		-foreground black -highlightcolor black -text Density -value False \
		-variable radiodensityvar 
    vTcl:DefineAlias "$site_5_0.rad68" "Radiobutton1" vTcl:WidgetProc "Toplevel1" 1
    menubutton $site_5_0.men69 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -menu "$site_5_0.men69.m" -padx 5 -pady 4 \
		-text {Solvents List} 
    vTcl:DefineAlias "$site_5_0.men69" "menudensity" vTcl:WidgetProc "Toplevel1" 1
    menu $site_5_0.men69.m \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-tearoff 0 
    vTcl:DefineAlias "$site_5_0.men69.m" "densitylist" vTcl:WidgetProc "" 1
    $site_5_0.men69.m add radiobutton \
		-value 0.0334 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {WAT - 0.0334} 
    $site_5_0.men69.m add radiobutton \
		-value 0.0564 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {ETA - 0.0564} 
    $site_5_0.men69.m add radiobutton \
		-value 0.002 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {PHE - 0.002} 
    $site_5_0.men69.m add radiobutton \
		-value 0.0334 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {WAT - 0.0334} 
    $site_5_0.men69.m add radiobutton \
		-value 0.0564 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {ETA - 0.0564} 
    $site_5_0.men69.m add radiobutton \
		-value 0.002 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {PHE - 0.002} 
    $site_5_0.men69.m add radiobutton \
		-value 0.0334 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {WAT - 0.0334} 
    $site_5_0.men69.m add radiobutton \
		-value 0.0564 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {ETA - 0.0564} 
    $site_5_0.men69.m add radiobutton \
		-value 0.002 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {PHE - 0.002} 
    $site_5_0.men69.m add radiobutton \
		-value 0.0334 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {WAT - 0.0334} 
    $site_5_0.men69.m add radiobutton \
		-value 0.0564 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {ETA - 0.0564} 
    $site_5_0.men69.m add radiobutton \
		-value 0.002 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {PHE - 0.002} 
    $site_5_0.men69.m add radiobutton \
		-value 0.0334 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {WAT - 0.0334} 
    $site_5_0.men69.m add radiobutton \
		-value 0.0564 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {ETA - 0.0564} 
    $site_5_0.men69.m add radiobutton \
		-value 0.002 -variable solventtype \
		-command {set ::SolventClust::density $solventtype} \
		-label {PHE - 0.002} 
    radiobutton $site_5_0.cpd70 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {activate_frame Button1 menudensity True
activate_frame Button1 Entrydensity      False} \
		-foreground black -highlightcolor black -text {Custom } -value True \
		-variable radiodensityvar 
    vTcl:DefineAlias "$site_5_0.cpd70" "customdensityradiobutton" vTcl:WidgetProc "Toplevel1" 1
    entry $site_5_0.ent71 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -selectbackground {#c4c4c4} \
		-selectforeground black -state disabled \
		-textvariable ::SolventClust::density 
    vTcl:DefineAlias "$site_5_0.ent71" "Entrydensity" vTcl:WidgetProc "Toplevel1" 1
    label $site_5_0.lab46 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text Resname 
    vTcl:DefineAlias "$site_5_0.lab46" "Label12" vTcl:WidgetProc "Toplevel1" 1
    label $site_5_0.cpd48 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Residence time} 
    vTcl:DefineAlias "$site_5_0.cpd48" "Label22" vTcl:WidgetProc "Toplevel1" 1
    label $site_5_0.cpd47 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Atom name} 
    vTcl:DefineAlias "$site_5_0.cpd47" "Label21" vTcl:WidgetProc "Toplevel1" 1
    checkbutton $site_5_0.che51 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text Compute -variable "$top\::che51" 
    vTcl:DefineAlias "$site_5_0.che51" "Checkbutton1" vTcl:WidgetProc "Toplevel1" 1
    entry $site_5_0.cpd55 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable ::SolventClust::step 
    vTcl:DefineAlias "$site_5_0.cpd55" "Entry10" vTcl:WidgetProc "Toplevel1" 1
    ::combobox2::combobox2 $site_5_0.com59 \
		-textvariable "$top\::com59" 
    vTcl:DefineAlias "$site_5_0.com59" "Combo2" vTcl:WidgetProc "Toplevel1" 1
    ::combobox2::combobox2 $site_5_0.cpd60 \
		-textvariable "$top\::com59" 
    vTcl:DefineAlias "$site_5_0.cpd60" "Combo3" vTcl:WidgetProc "Toplevel1" 1
    place $site_5_0.rad68 \
		-in $site_5_0 -x 425 -y 10 -anchor nw -bordermode ignore 
    place $site_5_0.men69 \
		-in $site_5_0 -x 500 -y 10 -width 120 -height 24 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd70 \
		-in $site_5_0 -x 426 -y 37 -width 78 -height 20 -anchor nw \
		-bordermode ignore 
    place $site_5_0.ent71 \
		-in $site_5_0 -x 525 -y 35 -width 60 -height 23 -anchor nw \
		-bordermode ignore 
    place $site_5_0.lab46 \
		-in $site_5_0 -x 35 -y 10 -anchor nw -bordermode ignore 
    place $site_5_0.cpd48 \
		-in $site_5_0 -x 240 -y 10 -width 109 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd47 \
		-in $site_5_0 -x 131 -y 10 -width 74 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_5_0.che51 \
		-in $site_5_0 -x 250 -y 25 -width 96 -height 20 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd55 \
		-in $site_5_0 -x 365 -y 26 -width 31 -height 20 -anchor nw \
		-bordermode ignore 
    place $site_5_0.com59 \
		-in $site_5_0 -x 25 -y 26 -width 82 -height 21 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd60 \
		-in $site_5_0 -x 131 -y 26 -width 82 -height 21 -anchor nw \
		-bordermode ignore 
    label $site_4_1.cpd49 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {MD step} 
    vTcl:DefineAlias "$site_4_1.cpd49" "Label13" vTcl:WidgetProc "Toplevel1" 1
    frame $site_4_1.cpd47 \
		-borderwidth 2 -relief groove -height 60 -highlightcolor black \
		-width 645 
    vTcl:DefineAlias "$site_4_1.cpd47" "Frame10" vTcl:WidgetProc "Toplevel1" 1
    set site_5_0 $site_4_1.cpd47
    label $site_5_0.lab48 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text NumberMin 
    vTcl:DefineAlias "$site_5_0.lab48" "Label15" vTcl:WidgetProc "Toplevel1" 1
    entry $site_5_0.ent49 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable ::SolventClust::watnumbermin 
    vTcl:DefineAlias "$site_5_0.ent49" "Entry5" vTcl:WidgetProc "Toplevel1" 1
    entry $site_5_0.ent53 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable ::SolventClust::WFRr 
    vTcl:DefineAlias "$site_5_0.ent53" "Entry7" vTcl:WidgetProc "Toplevel1" 1
    label $site_5_0.cpd54 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text dist 
    vTcl:DefineAlias "$site_5_0.cpd54" "Label16" vTcl:WidgetProc "Toplevel1" 1
    entry $site_5_0.cpd55 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable ::SolventClust::pop 
    vTcl:DefineAlias "$site_5_0.cpd55" "Entry8" vTcl:WidgetProc "Toplevel1" 1
    entry $site_5_0.cpd56 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable ::SolventClust::dist 
    vTcl:DefineAlias "$site_5_0.cpd56" "Entry9" vTcl:WidgetProc "Toplevel1" 1
    label $site_5_0.cpd58 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text dr 
    vTcl:DefineAlias "$site_5_0.cpd58" "Label17" vTcl:WidgetProc "Toplevel1" 1
    label $site_5_0.cpd59 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text Population 
    vTcl:DefineAlias "$site_5_0.cpd59" "Label18" vTcl:WidgetProc "Toplevel1" 1
    entry $site_5_0.cpd60 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable ::SolventClust::dr 
    vTcl:DefineAlias "$site_5_0.cpd60" "Entry11" vTcl:WidgetProc "Toplevel1" 1
    label $site_5_0.cpd61 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text WFRr 
    vTcl:DefineAlias "$site_5_0.cpd61" "Label19" vTcl:WidgetProc "Toplevel1" 1
    place $site_5_0.lab48 \
		-in $site_5_0 -x 29 -y 8 -width 74 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_5_0.ent49 \
		-in $site_5_0 -x 50 -y 25 -width 40 -height 23 -anchor nw \
		-bordermode ignore 
    place $site_5_0.ent53 \
		-in $site_5_0 -x 175 -y 25 -width 40 -height 23 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd54 \
		-in $site_5_0 -x 432 -y 8 -width 26 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd55 \
		-in $site_5_0 -x 300 -y 25 -width 40 -height 23 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd56 \
		-in $site_5_0 -x 425 -y 25 -width 40 -height 23 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd58 \
		-in $site_5_0 -x 561 -y 7 -width 17 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd59 \
		-in $site_5_0 -x 287 -y 7 -width 67 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd60 \
		-in $site_5_0 -x 550 -y 24 -width 40 -height 23 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd61 \
		-in $site_5_0 -x 175 -y 8 -anchor nw -bordermode inside 
    label $site_4_1.cpd62 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Clustering Parameters} 
    vTcl:DefineAlias "$site_4_1.cpd62" "Label20" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_1.but45 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Add Probe} 
    vTcl:DefineAlias "$site_4_1.but45" "Button3" vTcl:WidgetProc "Toplevel1" 1
    vTcl::widgets::bwidgets::scrolledwindow::createCmd $site_4_1.scr67 \
		-size 14 
    vTcl:DefineAlias "$site_4_1.scr67" "ScrolledWindow3" vTcl:WidgetProc "Toplevel1" 1
    ListBox $site_4_1.scr67.f.lis46 \
		-background white -highlightcolor black -selectbackground {#c4c4c4} \
		-selectforeground black \
		-xscrollcommand {ScrolledWindow::_set_hscroll .top44.not45.fpage2.scr67} \
		-yscrollcommand {ScrolledWindow::_set_vscroll .top44.not45.fpage2.scr67} 
    vTcl:DefineAlias "$site_4_1.scr67.f.lis46" "ListBox1" vTcl:WidgetProc "Toplevel1" 1
    bind $site_4_1.scr67.f.lis46 <Configure> {
        ListBox::_resize  %W
    }
    bind $site_4_1.scr67.f.lis46 <Destroy> {
        ListBox::_destroy %W
    }
    pack $site_4_1.scr67.f.lis46 -fill both -expand 1
    $site_4_1.scr67 setwidget $site_4_1.scr67.f
    button $site_4_1.cpd48 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Delete Probe} 
    vTcl:DefineAlias "$site_4_1.cpd48" "Button4" vTcl:WidgetProc "Toplevel1" 1
    place $site_4_1.cpd46 \
		-in $site_4_1 -x 5 -y 22 -width 645 -height 60 -anchor nw \
		-bordermode ignore 
    place $site_4_1.cpd49 \
		-in $site_4_1 -x 359 -y 30 -width 53 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_4_1.cpd47 \
		-in $site_4_1 -x 5 -y 92 -width 645 -height 60 -anchor nw \
		-bordermode ignore 
    place $site_4_1.cpd62 \
		-in $site_4_1 -x 10 -y 83 -width 137 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_4_1.but45 \
		-in $site_4_1 -x 95 -y 155 -width 152 -height 26 -anchor nw \
		-bordermode ignore 
    place $site_4_1.scr67 \
		-in $site_4_1 -x 5 -y 200 -width 651 -height 176 -anchor nw \
		-bordermode ignore 
    place $site_4_1.cpd48 \
		-in $site_4_1 -x 356 -y 155 -width 137 -height 26 -anchor nw \
		-bordermode ignore 
    set site_4_2 [$top.not45 getframe page3]
    frame $site_4_2.fra52 \
		-borderwidth 2 -relief groove -height 60 -highlightcolor black \
		-width 645 
    vTcl:DefineAlias "$site_4_2.fra52" "Frame3" vTcl:WidgetProc "Toplevel1" 1
    set site_5_0 $site_4_2.fra52
    ProgressBar $site_5_0.pro54 \
		-height 30 -troughcolor {#d9d9d9} -variable "$top\::pro54" 
    vTcl:DefineAlias "$site_5_0.pro54" "ProgressBar1" vTcl:WidgetProc "Toplevel1" 1
    place $site_5_0.pro54 \
		-in $site_5_0 -x 10 -y 18 -width 625 -height 30 -anchor nw \
		-bordermode ignore 
    label $site_4_2.lab53 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text Progress 
    vTcl:DefineAlias "$site_4_2.lab53" "Label11" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_2.but55 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Compute Site} 
    vTcl:DefineAlias "$site_4_2.but55" "Button2" vTcl:WidgetProc "Toplevel1" 1
    place $site_4_2.fra52 \
		-in $site_4_2 -x 5 -y 260 -width 645 -height 60 -anchor nw \
		-bordermode ignore 
    place $site_4_2.lab53 \
		-in $site_4_2 -x 15 -y 250 -anchor nw -bordermode ignore 
    place $site_4_2.but55 \
		-in $site_4_2 -x 220 -y 345 -width 212 -height 36 -anchor nw \
		-bordermode ignore 
    set site_4_3 [$top.not45 getframe page4]
    $top.not45 raise page1
    frame $top.cpd47 \
		-borderwidth 1 -relief sunken -height 24 -highlightcolor black \
		-width 658 
    vTcl:DefineAlias "$top.cpd47" "Frame2" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.cpd47
    menubutton $site_3_0.01 \
		-activebackground {#f9f9f9} -activeforeground black -anchor w \
		-foreground black -highlightcolor black -menu "$site_3_0.01.02" \
		-padx 4 -pady 3 -text File -width 4 
    vTcl:DefineAlias "$site_3_0.01" "Menubutton1" vTcl:WidgetProc "Toplevel1" 1
    menu $site_3_0.01.02 \
		-activebackground {#f9f9f9} -activeforeground black -font {Tahoma 8} \
		-foreground black -tearoff 0 
    vTcl:DefineAlias "$site_3_0.01.02" "Menu1" vTcl:WidgetProc "" 1
    $site_3_0.01.02 add command \
		-accelerator Ctrl+O -label Open 
    $site_3_0.01.02 add command \
		-accelerator Ctrl+W -command exit -label Close 
    menubutton $site_3_0.03 \
		-activebackground {#f9f9f9} -activeforeground black -anchor w \
		-foreground black -highlightcolor black -menu "$site_3_0.03.04" \
		-padx 4 -pady 3 -text Edit -width 4 
    vTcl:DefineAlias "$site_3_0.03" "Menubutton2" vTcl:WidgetProc "Toplevel1" 1
    menu $site_3_0.03.04 \
		-activebackground {#f9f9f9} -activeforeground black -font {Tahoma 8} \
		-foreground black -tearoff 0 
    vTcl:DefineAlias "$site_3_0.03.04" "Menu1" vTcl:WidgetProc "" 1
    $site_3_0.03.04 add command \
		-accelerator Ctrl+X -label Cut 
    $site_3_0.03.04 add command \
		-accelerator Ctrl+C -label Copy 
    $site_3_0.03.04 add command \
		-accelerator Ctrl+V -label Paste 
    $site_3_0.03.04 add command \
		-accelerator Del -label Delete 
    menubutton $site_3_0.05 \
		-activebackground {#f9f9f9} -activeforeground black -anchor w \
		-foreground black -highlightcolor black -menu "$site_3_0.05.06" \
		-padx 4 -pady 3 -text Help -width 4 
    vTcl:DefineAlias "$site_3_0.05" "Menubutton3" vTcl:WidgetProc "Toplevel1" 1
    menu $site_3_0.05.06 \
		-activebackground {#f9f9f9} -activeforeground black -font {Tahoma 8} \
		-foreground black -tearoff 0 
    vTcl:DefineAlias "$site_3_0.05.06" "Menu1" vTcl:WidgetProc "" 1
    $site_3_0.05.06 add command \
		-label About 
    pack $site_3_0.01 \
		-in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.03 \
		-in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.05 \
		-in $site_3_0 -anchor center -expand 0 -fill none -side right 
    label $top.lab47 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black \
		-image [vTcl:image:get_image [file join / home elias Escritorio watclust_package src logo.gif]] \
		-text label 
    vTcl:DefineAlias "$top.lab47" "Label2" vTcl:WidgetProc "Toplevel1" 1
    menu $top.m47 \
		-activebackground {#f9f9f9} -activeforeground black -cursor {} \
		-foreground black 
    ###################
    # SETTING GEOMETRY
    ###################
    place $top.not45 \
		-in $top -x 10 -y 135 -width 659 -height 429 -anchor nw \
		-bordermode ignore 
    place $top.cpd47 \
		-in $top -x 0 -y 0 -width 658 -height 24 -anchor nw \
		-bordermode inside 
    place $top.lab47 \
		-in $top -x 85 -y 35 -width 502 -height 103 -anchor nw \
		-bordermode ignore 

    vTcl:FireEvent $base <<Ready>>
}

#############################################################################
## Binding tag:  _TopLevel

bind "_TopLevel" <<Create>> {
    if {![info exists _topcount]} {set _topcount 0}; incr _topcount
}
bind "_TopLevel" <<DeleteWindow>> {
    if {[set ::%W::_modal]} {
                vTcl:Toplevel:WidgetProc %W endmodal
            } else {
                destroy %W; if {$_topcount == 0} {exit}
            }
}
bind "_TopLevel" <Destroy> {
    if {[winfo toplevel %W] == "%W"} {incr _topcount -1}
}

Window show .
Window show .top44

main $argc $argv
