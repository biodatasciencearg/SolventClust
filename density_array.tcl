set solvents_array {{WAT 0.0334} {ETA 0.0564} {PHE 0.002}}
proc load_solvents {solvents_array menubuttonobject} {
	foreach solvent $solvents_array {
		set solvent_label   [lindex $solvent 0]
		set solvent_density [lindex $solvent 1]
		puts "$solvent_label $solvent_density"
		$widget($menubuttonobject) add command -label "${solvent_label}-${solvent_density}" -command {set density ${solvent_density} }
	}
}
