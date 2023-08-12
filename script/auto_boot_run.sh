#!/bin/bash
set -v
echo "[Install]" >> /lib/systemd/system/rc-local.service
echo "WantedBy=multi-user.target" >> /lib/systemd/system/rc-local.service
systemctl enable rc-local
echo "#!/bin/bash -e" >> /etc/rc.local
#密钥拷贝过去
echo "su - jiaao -c \"autossh -M 4010 -NR 8888:localhost:22 ubuntu@xx.xx.xx.xx  &\"" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local
chmod 755 /etc/rc.local
#systemctl status rc-local 查看rc-local模块运行日志