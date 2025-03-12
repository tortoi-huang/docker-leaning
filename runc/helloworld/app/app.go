package main

import (
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
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

	root := "/"
	fmt.Println(root)
	err = printDir(root, "", 0, 1) // maxDepth=1 表示两级（根目录+一级子目录）
	if err != nil {
		fmt.Fprintf(os.Stderr, "错误: %v\n", err)
		os.Exit(1)
	}

	http.HandleFunc("/", handler)
	port := getPort()
	addr := ":" + port
	fmt.Printf("服务器启动，监听在 http://localhost%s\n", addr)

	err = http.ListenAndServe(addr, nil)
	if err != nil {
		log.Fatalf("服务器启动失败: %v", err)
	}
}

func printDir(dirPath string, prefix string, depth int, maxDepth int) error {
	// 打开目录
	dir, err := os.Open(dirPath)
	if err != nil {
		return fmt.Errorf("无法打开目录 %s: %v", dirPath, err)
	}
	defer dir.Close()

	// 读取目录内容
	entries, err := dir.Readdir(-1)
	if err != nil {
		return fmt.Errorf("无法读取目录 %s: %v", dirPath, err)
	}

	// 遍历目录项
	for i, entry := range entries {
		// 构建当前项的完整路径
		fullPath := filepath.Join(dirPath, entry.Name())

		// 判断是否为最后一项，用于调整前缀
		isLast := i == len(entries)-1
		currentPrefix := prefix
		if depth > 0 {
			if isLast {
				currentPrefix += "└── "
			} else {
				currentPrefix += "├── "
			}
		}

		// 打印当前项
		fmt.Printf("%s%s\n", currentPrefix, entry.Name())

		// 如果是目录且未达到最大深度，递归打印
		if entry.IsDir() && depth < maxDepth {
			newPrefix := prefix
			if depth > 0 {
				if isLast {
					newPrefix += "    "
				} else {
					newPrefix += "│   "
				}
			}
			err := printDir(fullPath, newPrefix, depth+1, maxDepth)
			if err != nil {
				fmt.Printf("错误: %v\n", err)
			}
		}
	}

	return nil
}

func handler(w http.ResponseWriter, r *http.Request) {
	// 设置响应状态码为 200 OK（默认值，可省略）
	w.WriteHeader(http.StatusOK)
	// 设置响应内容类型为纯文本
	w.Header().Set("Content-Type", "text/plain")
	// 向客户端写入 "Hello, World!"
	_, err := fmt.Fprintf(w, "Hello, World!")
	if err != nil {
		log.Printf("写入响应失败: %v", err)
	}
}

func getPort() string {
	port := os.Getenv("APP_PORT")
	if port == "" {
		return "8080" // 未设置环境变量时使用默认值
	}

	// 验证端口号是否为有效整数且在合理范围内
	if p, err := strconv.Atoi(port); err != nil || p < 1 || p > 65535 {
		log.Printf("无效的端口号 %s，使用默认端口 8080", port)
		return "8080"
	}

	return port
}
