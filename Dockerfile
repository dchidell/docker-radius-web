FROM alpine:3.8 as build
MAINTAINER David Chidell (dchidell@cisco.com)
ENV VERSION=201712190728
ENV TAC_PLUS_BIN=/tacacs/sbin/tac_plus

FROM build as webproc
ENV WEBPROC_VERSION 0.2.2
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/$WEBPROC_VERSION/webproc_linux_amd64.gz
RUN apk add --no-cache curl
RUN curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc
RUN chmod +x /usr/local/bin/webproc

FROM build as snmptrap
RUN apk --no-cache add freeradius
COPY --from=webproc /usr/local/bin/webproc /usr/local/bin/webproc

ADD clients.conf /etc/raddb/clients.conf
ADD users /etc/raddb/users
ADD radiusd.conf /etc/raddb/radiusd.conf
RUN chmod -R o-w /etc/raddb/
ENTRYPOINT ["webproc","--on-exit","restart","--config","/etc/raddb/users,/etc/raddb/clients.conf,etc/raddb/radiusd.conf","--","radiusd","-f","-l","stdout"]