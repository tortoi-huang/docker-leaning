package main

import (
	"fmt"
	"net"
	"os"
)

func main() {
	// 获取当前工作目录
	dir, err := os.Getwd()
	if err != nil {
		fmt.Println("获取当前目录失败: ", err)
		return
	}
	fmt.Println("应用程序运行目录: ", dir)

	fmt.Println("\n系统环境变量: ")
	// 获取所有环境变量
	envVars := os.Environ()
	// 遍历并打印每个环境变量
	for _, env := range envVars {
		fmt.Println(env)
	}
	// 获取并打印所有网络接口
	interfaces, err := net.Interfaces()
	if err != nil {
		fmt.Println("获取网络接口失败:", err)
		return
	}
	fmt.Println("\n网络接口:")
	for _, iface := range interfaces {
		fmt.Printf("接口名称: %s, MAC地址: %s, 状态: %v\n", iface.Name, iface.HardwareAddr, iface.Flags)
		// 获取该接口的IP地址
		addrs, err := iface.Addrs()
		if err != nil {
			fmt.Println("  获取IP地址失败:", err)
			continue
		}
		for _, addr := range addrs {
			fmt.Println("  IP地址:", addr)
		}
	}
}
