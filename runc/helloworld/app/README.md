# 示例程序
```bash
# 运行
go run app.go

# 编译, CGO_ENABLED=0 表示打包所有依赖, 不使用此项会导致编译的文件会依赖操作系统的库，可能在容器中出现问题
CGO_ENABLED=0 go build app.go

# 检查是否有依赖, 如果显示有依赖则可能导致错误
ldd ./app
```