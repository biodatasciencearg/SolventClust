proc spendTime {steps} {
	for {set i 0} {$i<$steps} {incr i} {
		after 100
		puts "step $i"
	}
}
spendTime 20
