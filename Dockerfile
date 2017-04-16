FROM centos:centos6

MAINTAINER coleman <coleman_dlut@hotmail.com>

ENV MAILDOMAIN localhost
ENV TLS_CERT_FILE "/etc/pki/tls/certs/server.pem"
ENV TLS_KEY_FILE "/etc/pki/tls/certs/server.pem"

#************************************************************
#*  Updateし、postfix、cyrus-imapd、cyrus-sasl-md5、cyrus-saslをインストールする                       *
#************************************************************
RUN yum -y update && yum -y install postfix dovecot && yum clean all

#/etc/postfix/main.cfの変更
RUN sed -i -e "/^#myhostname = virtual\.domain\.tld/a myhostname = centos\.freemail\.server-on\.net" /etc/postfix/main.cf && \
sed -i -e "/^#mydomain = domain.tld/a mydomain = freemail.server-on.net" /etc/postfix/main.cf && \
sed -i -e "s/^#myorigin = \$mydomain/myorigin = \$mydomain/" /etc/postfix/main.cf && \
sed -i -e "s/^#inet_interfaces = all/inet_interfaces = all/" /etc/postfix/main.cf && \
sed -i -e "s/^inet_interfaces = localhost/#inet_interfaces = localhost/" /etc/postfix/main.cf && \
sed -i -e "s/^inet_protocols = all/inet_protocols = ipv4/" /etc/postfix/main.cf && \
sed -i -e "s/^#home_mailbox = Maildir\//home_mailbox = Maildir\//" /etc/postfix/main.cf && \
sed -i -e "/^#smtpd_banner = \$myhostname ESMTP \$mail_name (\$mail_version)/a smtpd_banner = \$myhostname ESMTP unknown" /etc/postfix/main.cf && \
sed -i -e "$ a \ " /etc/postfix/main.cf && \
sed -i -e "$ a smtpd_sasl_auth_enable = yes" /etc/postfix/main.cf && \
sed -i -e "$ a smtpd_sasl_type = dovecot" /etc/postfix/main.cf && \
sed -i -e "$ a smtpd_sasl_path = private/auth" /etc/postfix/main.cf && \
sed -i -e "$ a smtpd_sasl_local_domain = \$mydomain" /etc/postfix/main.cf && \
sed -i -e "$ a smtpd_sasl_security_options = noanonymous" /etc/postfix/main.cf && \
sed -i -e "$ a smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination" /etc/postfix/main.cf && \
sed -i -e "$ a broken_sasl_auth_clients = yes" /etc/postfix/main.cf && \
sed -i -e "$ a mailbox_size_limit = 0" /etc/postfix/main.cf && \
sed -i -e "$ a message_size_limit = 0" /etc/postfix/main.cf && \
sed -i -e "$ a virtual_mailbox_domains = freemail\.server-on\.net" /etc/postfix/main.cf && \
sed -i -e "$ a virtual_mailbox_base = \/var\/spool\/virtual" /etc/postfix/main.cf && \
sed -i -e "$ a virtual_mailbox_maps = hash:\/etc\/postfix\/vmailbox" /etc/postfix/main.cf && \
sed -i -e "$ a virtual_minimum_uid = 100" /etc/postfix/main.cf && \
sed -i -e "$ a virtual_uid_maps = static:500" /etc/postfix/main.cf && \
sed -i -e "$ a virtual_gid_maps = static:500" /etc/postfix/main.cf && \
sed -i -e "$ a virtual_mailbox_limit = 0" /etc/postfix/main.cf

RUN useradd vmail && \
sed -i -e "s/\/home\/vmail:\/bin\/bash/\/var\/spool\/virtual:\/sbin\/nologin/" /etc/passwd && \
mkdir /var/spool/virtual && \
chown vmail:vmail /var/spool/virtual

#/etc/postfix/master.cfの変更
RUN sed -i -e "s/^#submission inet n/submission inet n/" /etc/postfix/master.cf && \
sed -i -e "s/^#  -o smtpd_tls_security_level=encrypt/  -o smtpd_tls_security_level=may/" /etc/postfix/master.cf && \
sed -i -e "s/^#  -o smtpd_sasl_auth_enable=yes/  -o smtpd_sasl_auth_enable=yes/" /etc/postfix/master.cf && \
sed -i -e "s/^#  -o smtpd_client_restrictions=permit_sasl_authenticated,reject/  -o smtpd_client_restrictions=permit_sasl_authenticated,reject/" /etc/postfix/master.cf && \
sed -i -e "s/^#smtps     inet  n/smtps     inet  n/" /etc/postfix/master.cf && \
sed -i -e "s/^#  -o smtpd_tls_wrappermode=yes/  -o smtpd_tls_wrappermode=yes/" /etc/postfix/master.cf && \
sed -i -e "s/^#  -o smtpd_sasl_auth_enable=yes/  -o smtpd_sasl_auth_enable=yes/" /etc/postfix/master.cf && \
sed -i -e "s/^#  -o smtpd_client_restrictions=permit_sasl_authenticated,reject/  -o smtpd_client_restrictions=permit_sasl_authenticated,reject/" /etc/postfix/master.cf

#/etc/dovecot/dovecot.confの変更
RUN sed -i -e "s/^#protocols = imap pop3 lmtp/protocols = imap lmtp/" /etc/dovecot/dovecot.conf && \
sed -i -e "/^#listen = \*, ::/a listen = \*" /etc/dovecot/dovecot.conf

#/etc/dovecot/conf.d/10-auth.confの変更
RUN sed -i -e "s/^auth_mechanisms = plain/auth_mechanisms = plain login digest-md5 cram-md5/" /etc/dovecot/conf.d/10-auth.conf && \
sed -i -e "s/^\!include auth-system\.conf\.ext/#\!include auth-system\.conf\.ext/" /etc/dovecot/conf.d/10-auth.conf && \
sed -i -e "s/^#\!include auth-passwdfile\.conf\.ext/\!include auth-passwdfile\.conf\.ext/" /etc/dovecot/conf.d/10-auth.conf && \
sed -i -e "s/^#\!include auth-static\.conf\.ext/\!include auth-static\.conf\.ext/" /etc/dovecot/conf.d/10-auth.conf

RUN sed -i -e "s/^#mail_location =/mail_location = maildir:~\/Maildir/" /etc/dovecot/conf.d/10-mail.conf

RUN sed -i -e "s/^userdb {/#userdb {/" /etc/dovecot/conf.d/auth-passwdfile.conf.ext && \
sed -i -e "12s/^  driver = passwd-file/#  driver = passwd-file/" /etc/dovecot/conf.d/auth-passwdfile.conf.ext && \
sed -i -e "s/^  args = username_format=%u \/etc\/dovecot\/users/#  args = username_format=%u \/etc\/dovecot\/users/" /etc/dovecot/conf.d/auth-passwdfile.conf.ext && \
sed -i -e "14s/^}/#}/" /etc/dovecot/conf.d/auth-passwdfile.conf.ext

RUN sed -i -e "21,24s/^#//" /etc/dovecot/conf.d/auth-static.conf.ext && \
sed -i -e"s/  args = uid=vmail gid=vmail home=\/home\/%u/  args = uid=vmail gid=vmail home=\/var\/spool\/virtual\/%d\/%n/" /etc/dovecot/conf.d/auth-static.conf.ext

RUN sed -i -e "88,90s/#//" /etc/dovecot/conf.d/10-master.conf

CMD bash -c "/sbin/service postfix start && /sbin/service dovecot start && /bin/bash"
