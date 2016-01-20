FROM centos
RUN yum install -y ruby ruby-devel rubygems gcc-c++ make git
RUN mkdir -p /opt/premailer-api
ADD ./Gemfile /opt/premailer-api/
ADD ./Gemfile.lock /opt/premailer-api/
RUN gem install bundler
WORKDIR /opt/premailer-api
RUN bundle install
EXPOSE 4567
CMD ["ruby", "premailer-api.rb", "-o", "0.0.0.0"]
#ADD ./premailer-api.rb /opt/premailer-api/
