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
    set site_6_0 $site_5_0.fra45
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
		-highlightcolor black 
    wm focusmodel $top passive
    wm geometry $top 693x578+96+101; update
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
		-borderwidth 2 -relief groove -height 85 -highlightcolor black \
		-width 645 
    vTcl:DefineAlias "$site_4_1.cpd46" "Frame9" vTcl:WidgetProc "Toplevel1" 1
    set site_5_0 $site_4_1.cpd46
    frame $site_5_0.fra45 \
		-borderwidth 2 -relief groove -height 65 -highlightcolor black \
		-width 140 
    vTcl:DefineAlias "$site_5_0.fra45" "Frame5" vTcl:WidgetProc "Toplevel1" 1
    set site_6_0 $site_5_0.fra45
    menubutton $site_6_0.men47 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -menu "$site_6_0.men47.m" -padx 5 -pady 4 \
		-relief raised -text {1ERK 2ERK} \
		-textvariable ::SolventClust::molecules 
    vTcl:DefineAlias "$site_6_0.men47" "ResnameButton2" vTcl:WidgetProc "Toplevel1" 1
    menu $site_6_0.men47.m \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-tearoff 0 
    label $site_6_0.lab46 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text Resname 
    vTcl:DefineAlias "$site_6_0.lab46" "Label12" vTcl:WidgetProc "Toplevel1" 1
    place $site_6_0.men47 \
		-in $site_6_0 -x 20 -y 30 -width 82 -height 24 -anchor nw \
		-bordermode ignore 
    place $site_6_0.lab46 \
		-in $site_6_0 -x 35 -y 5 -anchor nw -bordermode ignore 
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
    place $site_5_0.fra45 \
		-in $site_5_0 -x 15 -y 10 -width 140 -height 65 -anchor nw \
		-bordermode ignore 
    place $site_5_0.rad68 \
		-in $site_5_0 -x 425 -y 10 -anchor nw -bordermode ignore 
    place $site_5_0.men69 \
		-in $site_5_0 -x 500 -y 10 -width 120 -height 24 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd70 \
		-in $site_5_0 -x 425 -y 50 -anchor nw -bordermode inside 
    place $site_5_0.ent71 \
		-in $site_5_0 -x 525 -y 50 -width 60 -height 23 -anchor nw \
		-bordermode ignore 
    label $site_4_1.cpd49 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Probe selection} 
    vTcl:DefineAlias "$site_4_1.cpd49" "Label13" vTcl:WidgetProc "Toplevel1" 1
    frame $site_4_1.cpd47 \
		-borderwidth 2 -relief groove -height 85 -highlightcolor black \
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
    place $site_4_1.cpd46 \
		-in $site_4_1 -x 5 -y 22 -width 645 -height 85 -anchor nw \
		-bordermode ignore 
    place $site_4_1.cpd49 \
		-in $site_4_1 -x 0 -y 0 -anchor nw -bordermode inside 
    place $site_4_1.cpd47 \
		-in $site_4_1 -x 5 -y 129 -width 645 -height 85 -anchor nw \
		-bordermode ignore 
    place $site_4_1.cpd62 \
		-in $site_4_1 -x 10 -y 120 -width 137 -height 18 -anchor nw \
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
    ###################
    # SETTING GEOMETRY
    ###################
    place $top.not45 \
		-in $top -x 10 -y 140 -width 659 -height 429 -anchor nw \
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
