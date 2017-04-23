# postfix-dovecot

# 利用方法
docker run -p 25:25 -p 587:587 -p 465:465 -p 143:143 -p 993:993 \
           -e "MAIL_SERVER_DOMAIN_NAME=xxxx.com"   \
           -v /Maildir/maildata:/var/spool/virtual  \
           -v /Maildir/mailconf:/Maildir/mailconf  \
           -v /etc/pki/tls/certs:/etc/pki/tls/certs \
           -it -h mail colemandlut/postfix-dovecot

更改上面的xxxx.com为实际的邮件域名
/Maildir/maildata存储邮件文件
/Maildir/mailconf存储用户信息
需要设定postfix的virtual mail box的信息，和dovecot的users的信息

vi /Maildir/mailconf/vmailbox
aaa@xxx.com xxx.com/aaa/Maildir/

用doveadm pw生成密码，写入下面的文件
vi /Maildir/mailconf/users
aaa@xxx.com:{CRAM-MD5}4c4f1d6305e5505e66630ded6bf16a9b05b28f73377f3f68921076f20479937c

/etc/pki/tls/certs有服务器的证书

