package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
)

var (
	NoCowTargets   = []string{"/var/lib/libvirt/images", "/var/lib/mysql", "/var/lib/pgsql", "/var/lib/docker/btrfs"}
	DefaultMount   = "/"
	DataUsageLimit = "50"
	MetaUsageLimit = "50"
)

func executeSysCommand(name string, args ...string) {
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		log.Printf("Execution failed for %s: %v\n", name, err)
	}
}

func disableCow(dirs []string) {
	for _, dir := range dirs {
		if err := os.MkdirAll(dir, 0755); err != nil {
			log.Printf("Directory creation failed for %s: %v\n", dir, err)
			continue
		}
		executeSysCommand("chattr", "+C", dir)
	}
}

func balanceChunks(mount string, dUsage string, mUsage string) {
	dFlag := fmt.Sprintf("-dusage=%s", dUsage)
	mFlag := fmt.Sprintf("-musage=%s", mUsage)
	executeSysCommand("btrfs", "balance", "start", dFlag, mFlag, mount)
}

func defragFilesystem(mount string) {
	executeSysCommand("btrfs", "filesystem", "defragment", "-r", mount)
}

func main() {
	mountPtr := flag.String("mount", DefaultMount, "BTRFS mount point")
	dUsagePtr := flag.String("dusage", DataUsageLimit, "Data usage threshold")
	mUsagePtr := flag.String("musage", MetaUsageLimit, "Metadata usage threshold")
	flag.Parse()

	disableCow(NoCowTargets)
	balanceChunks(*mountPtr, *dUsagePtr, *mUsagePtr)
	defragFilesystem(*mountPtr)
}

