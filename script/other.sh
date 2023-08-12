docker run --network=host --name=brpc  -it -d --rm -v /code:/code  f2501b91d66e tail -f /dev/null
watch -n.1 "grep \"^[c]pu MHz\" /proc/cpuinfo"
docker run -itd jiaaobai/nvim_env:v0.0.2   tail -f /dev/null
docker tag c81111d549a0 jiaaobai/nvim_env:v0.0.2.1
