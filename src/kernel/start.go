package kernel

func start() {
	for { // loop forever. 
	}
}


func try(arg1 int, arg2 int, arg3 int) int {
  if arg3 < 0 { 
	panic("Panic!")
  }  
  return arg1+arg2+arg3
}
