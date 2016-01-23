FROM phusion/baseimage:latest
RUN apt-get update
RUN apt-get install -y ruby ruby-dev g++ make git
RUN mkdir -p /opt/premailer-api
WORKDIR /opt/premailer-api
EXPOSE 4567
RUN gem install bundle rack --no-rdoc --no-ri

ADD ./init.sh /init.sh
RUN chmod +x /init.sh
RUN apt-get install -y redis-tools zlib1g-dev 
RUN apt-get install -y dnsutils
RUN apt-get install -y dnsmasq

RUN useradd -ms /bin/bash ruby
CMD ["bash","/init.sh"]
RUN echo nameserver 127.0.0.1 >/etc/resolv.conf
# as usual, thanks arch https://wiki.archlinux.org/index.php/dnsmasq#resolv.conf
RUN echo nameserver 8.8.8.8 >/etc/resolv.conf
RUN echo nohook resolv.conf >/etc/dhcpcd.conf
USER ruby

# External nameservers
#ADD ./premailer-api.rb /opt/premailer-api/
