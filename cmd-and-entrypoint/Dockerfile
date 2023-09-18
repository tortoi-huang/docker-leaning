#FROM alpine:20230901
FROM ubuntu:20.04

COPY ./mybin /opt/mybin
WORKDIR /opt/mybin
RUN chmod +x ./*.sh

# docker run会运行 ENTRYPOINT 指令，如果docker run 提供了参数则将参数拼接到ENTRYPOINT后面，如果没有则使用CMD指令作为默认参数
ENTRYPOINT ["/opt/mybin/entrypoint.sh","param1","param2"] 
# CMD会拼接到如果ENTRYPOINT后面（空格分隔开），如果ENTRYPOINT为空则会使用继承镜像的ENTRYPOINT（ubuntu:20.04，会执行bash）
CMD ["/opt/mybin/cmd.sh","param3", "param4"]