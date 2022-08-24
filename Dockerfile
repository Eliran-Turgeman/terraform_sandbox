FROM amazonlinux:2
WORKDIR /opt/cloudmapper
ENV secret = AKIAIOSFODNN7EXAMAAA

RUN yum update -y && yum install -y dracut-fips openssl
RUN yum install -y python3 python3-pip
RUN yum install -y bash musl-dev gcc build-essential autoconf libtool python3-tk jq awscli git
RUN yum install -y automake python3-devel python3-tkinter
