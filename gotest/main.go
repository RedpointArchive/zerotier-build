package main

// #cgo CFLAGS: -std=c11 -w -DGOLANG_CGO=1
// #cgo LDFLAGS: -L${SRCDIR}/../libzt/bin/lib -lztunified -lstdc++ -lws2_32 -lShLwApi -liphlpapi
// #include "../libzt/include/libzt.h"
import "C"
import (
	"fmt"
	"os"
)

func main() {
	os.MkdirAll("zt_config/path", 0644)

	C.zts_set_service_port(9102)
    
	fmt.Println("starting zerotier")
	res := C.zts_startjoin(C.CString("zt_config/path"), 0x8056c2e21c000001)
	if res != 0 {
		fmt.Println("zerotier can't start")
		os.Exit(1)
	}
/*
	fmt.Println("joining network")
	res = C.zts_join(0xb6079f73c66e4c60)
	if res != 0 {
		fmt.Println("zerotier can't join network")
		os.Exit(1)
	}

	fmt.Println("waiting for zerotier to join...")
	for C.zts_has_address(0xb6079f73c66e4c60) == 0 {
		time.Sleep(time.Second * 1)
		fmt.Println("waiting for zerotier to join...")
	}

	fmt.Println("leaving network")
	res = C.zts_leave(0xb6079f73c66e4c60)
	if res != 0 {
		fmt.Println("zerotier can't leave network")
		os.Exit(1)
	}*/

	fmt.Println("done")
	C.zts_stop()

	//C.zts_startjoin(C.CString("./"), 0xb6079f73c66e4c60)

	//C.zts_leave(0xb6079f73c66e4c60)
	//
}
