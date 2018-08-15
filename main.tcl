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
    set site_6_0 $site_5_0.cpd99
    set site_5_0 $site_4_0.cpd94
    set site_6_0 $site_5_0.fra45
    set site_4_1 [$base.not45 getframe page2]
    set site_4_2 [$base.not45 getframe page3]
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
}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {}

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
    wm geometry $top 693x583+217+109; update
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
		-text {Output Settings} 
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
		-borderwidth 2 -relief groove -height 230 -highlightcolor black \
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
		-selectforeground black -textvariable {"protein"} 
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
    vTcl:DefineAlias "$site_6_0.men115" "Menubutton4" vTcl:WidgetProc "Toplevel1" 1
    menu $site_6_0.men115.m \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-tearoff 0 
    place $site_6_0.ent102 \
		-in $site_6_0 -x 25 -y 36 -width 241 -height 25 -anchor nw \
		-bordermode ignore 
    place $site_6_0.lab104 \
		-in $site_6_0 -x 116 -y 17 -width 59 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_6_0.lab109 \
		-in $site_6_0 -x 417 -y 20 -width 97 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_6_0.men115 \
		-in $site_6_0 -x 335 -y 35 -width 247 -height 24 -anchor nw \
		-bordermode ignore 
    frame $site_5_0.cpd99 \
		-borderwidth 2 -relief groove -height 75 -highlightcolor black \
		-width 620 
    vTcl:DefineAlias "$site_5_0.cpd99" "Frame8" vTcl:WidgetProc "Toplevel1" 1
    set site_6_0 $site_5_0.cpd99
    entry $site_6_0.cpd103 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable "$top\::ent102" 
    vTcl:DefineAlias "$site_6_0.cpd103" "Entry2" vTcl:WidgetProc "Toplevel1" 1
    label $site_6_0.cpd105 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text Selection 
    vTcl:DefineAlias "$site_6_0.cpd105" "Label7" vTcl:WidgetProc "Toplevel1" 1
    menubutton $site_6_0.cpd107 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -menu "$site_5_0.fra98.men106.m" -padx 5 \
		-pady 4 -text menu 
    vTcl:DefineAlias "$site_6_0.cpd107" "Menubutton5" vTcl:WidgetProc "Toplevel1" 1
    label $site_6_0.cpd110 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Select Molecule} 
    vTcl:DefineAlias "$site_6_0.cpd110" "Label9" vTcl:WidgetProc "Toplevel1" 1
    entry $site_6_0.ent112 \
		-background white -foreground black -highlightcolor black \
		-insertbackground black -selectbackground {#c4c4c4} \
		-selectforeground black -textvariable "$top\::ent112" 
    vTcl:DefineAlias "$site_6_0.ent112" "Entry3" vTcl:WidgetProc "Toplevel1" 1
    label $site_6_0.lab113 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text Frame: 
    vTcl:DefineAlias "$site_6_0.lab113" "Label10" vTcl:WidgetProc "Toplevel1" 1
    menubutton $site_6_0.men44 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -menu "$site_6_0.men44.m" -padx 5 -pady 4 \
		-text menu 
    vTcl:DefineAlias "$site_6_0.men44" "Menubutton6" vTcl:WidgetProc "Toplevel1" 1
    menu $site_6_0.men44.m \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-tearoff 0 
    place $site_6_0.cpd103 \
		-in $site_6_0 -x 28 -y 31 -width 236 -height 30 -anchor nw \
		-bordermode ignore 
    place $site_6_0.cpd105 \
		-in $site_6_0 -x 115 -y 10 -anchor nw -bordermode inside 
    place $site_6_0.cpd110 \
		-in $site_6_0 -x 324 -y 17 -width 97 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_6_0.ent112 \
		-in $site_6_0 -x 530 -y 30 -width 71 -height 25 -anchor nw \
		-bordermode ignore 
    place $site_6_0.lab113 \
		-in $site_6_0 -x 480 -y 34 -width 46 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_6_0.men44 \
		-in $site_6_0 -x 290 -y 35 -width 167 -height 24 -anchor nw \
		-bordermode ignore 
    label $site_5_0.lab100 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Use Molecule:} 
    vTcl:DefineAlias "$site_5_0.lab100" "Label4" vTcl:WidgetProc "Toplevel1" 1
    label $site_5_0.lab101 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Reference Molecule} 
    vTcl:DefineAlias "$site_5_0.lab101" "Label5" vTcl:WidgetProc "Toplevel1" 1
    place $site_5_0.fra98 \
		-in $site_5_0 -x 11 -y 29 -width 620 -height 75 -anchor nw \
		-bordermode ignore 
    place $site_5_0.cpd99 \
		-in $site_5_0 -x 15 -y 140 -width 620 -height 75 -anchor nw \
		-bordermode ignore 
    place $site_5_0.lab100 \
		-in $site_5_0 -x 260 -y 20 -anchor nw -bordermode ignore 
    place $site_5_0.lab101 \
		-in $site_5_0 -x 250 -y 130 -anchor nw -bordermode ignore 
    frame $site_4_0.cpd94 \
		-borderwidth 2 -relief groove -height 85 -highlightcolor black \
		-width 645 
    vTcl:DefineAlias "$site_4_0.cpd94" "Frame7" vTcl:WidgetProc "Toplevel1" 1
    set site_5_0 $site_4_0.cpd94
    message $site_5_0.mes46 \
		-foreground black -highlightcolor black \
		-text {***********INFORMATION***********
In order to calculate the sites, 
you must select the corresponding 
atom(s) to be used  as a probe.} \
		-width 250 
    vTcl:DefineAlias "$site_5_0.mes46" "Message1" vTcl:WidgetProc "Toplevel1" 1
    frame $site_5_0.fra45 \
		-borderwidth 2 -relief groove -height 75 -width 145 
    vTcl:DefineAlias "$site_5_0.fra45" "Frame3" vTcl:WidgetProc "Toplevel1" 1
    set site_6_0 $site_5_0.fra45
    menubutton $site_6_0.men47 \
		-menu "$site_6_0.men47.m" -padx 5 -pady 4 -relief raised \
		-text Resname -textvariable ::SolventClust::molecules 
    vTcl:DefineAlias "$site_6_0.men47" "ResnameButton" vTcl:WidgetProc "Toplevel1" 1
    menu $site_6_0.men47.m \
		-tearoff 0 
    label $site_6_0.lab46 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text Resname 
    vTcl:DefineAlias "$site_6_0.lab46" "Label11" vTcl:WidgetProc "Toplevel1" 1
    place $site_6_0.men47 \
		-in $site_6_0 -x 20 -y 30 -width 92 -height 34 -anchor nw \
		-bordermode ignore 
    place $site_6_0.lab46 \
		-in $site_6_0 -x 35 -y 5 -anchor nw -bordermode ignore 
    place $site_5_0.mes46 \
		-in $site_5_0 -x 15 -y 15 -width 250 -height 55 -anchor nw \
		-bordermode ignore 
    place $site_5_0.fra45 \
		-in $site_5_0 -x 260 -y 5 -width 145 -height 75 -anchor nw \
		-bordermode ignore 
    label $site_4_0.lab95 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Fitting Options} 
    vTcl:DefineAlias "$site_4_0.lab95" "Label1" vTcl:WidgetProc "Toplevel1" 1
    label $site_4_0.lab97 \
		-activebackground {#f9f9f9} -activeforeground black -foreground black \
		-highlightcolor black -text {Probe selection} 
    vTcl:DefineAlias "$site_4_0.lab97" "Label3" vTcl:WidgetProc "Toplevel1" 1
    button $site_4_0.but114 \
		-activebackground {#f9f9f9} -activeforeground black \
		-command {#.top44.not45 getframe .top44.not45.cpd99
puts $::SolventClust::molecules} \
		-foreground black -highlightcolor black -text Next 
    vTcl:DefineAlias "$site_4_0.but114" "Button1" vTcl:WidgetProc "Toplevel1" 1
    place $site_4_0.fra92 \
		-in $site_4_0 -x 4 -y 20 -width 645 -height 230 -anchor nw \
		-bordermode ignore 
    place $site_4_0.cpd94 \
		-in $site_4_0 -x 5 -y 266 -width 645 -height 85 -anchor nw \
		-bordermode ignore 
    place $site_4_0.lab95 \
		-in $site_4_0 -x 20 -y 10 -anchor nw -bordermode ignore 
    place $site_4_0.lab97 \
		-in $site_4_0 -x 15 -y 256 -width 95 -height 18 -anchor nw \
		-bordermode ignore 
    place $site_4_0.but114 \
		-in $site_4_0 -x 570 -y 360 -width 69 -height 26 -anchor nw \
		-bordermode ignore 
    set site_4_1 [$top.not45 getframe page2]
    set site_4_2 [$top.not45 getframe page3]
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
		-accelerator Ctrl+W -label Close 
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
		-in $top -x 5 -y 145 -width 659 -height 429 -anchor nw \
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
