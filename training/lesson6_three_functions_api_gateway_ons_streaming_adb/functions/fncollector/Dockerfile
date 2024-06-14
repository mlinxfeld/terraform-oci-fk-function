FROM oraclelinux:8-slim as ol8

# Install dependencies
RUN microdnf -y install dnf
RUN microdnf -y install oracle-release-el8
RUN dnf config-manager --enable ol8_oracle_instantclient
RUN microdnf -y install oracle-instantclient19.23-basic

# Installing Python
RUN   microdnf repolist && \
      microdnf module enable python38 && \
      microdnf repolist && \
      microdnf install python38 && \
      microdnf install python38-pip && \
      microdnf install libaio && \
      microdnf install openssh-clients && \
      microdnf install findutils && \
      microdnf install less && \
      microdnf install wget && \
      microdnf clean all && \
      pip3 install -U pip && \
      pip3 install -U setuptools && \
      pip3 install -U cryptography

# Install GCC and other development tools
RUN dnf -y groupinstall "Development Tools" && \
    dnf -y install python3-devel libaio-devel

# Updating the packages
RUN  microdnf update && \
     microdnf clean all

WORKDIR /function
ADD requirements.txt /function/

RUN pip3 install --target /python/  --no-cache --no-cache-dir -r requirements.txt && \
  rm -fr ~/.cache/pip /tmp* requirements.txt func.yaml Dockerfile .venv && \
  chmod -R o+r /python
ADD . /function/
RUN rm -fr /function/.pip_cache

RUN groupadd --gid 1000 fn && adduser --uid 1000 --gid fn fn
RUN mkdir -p /tmp/
RUN chmod -R 777 /tmp/
RUN mkdir -p /home/fn/.ssh
RUN chown -R fn:fn /tmp/
RUN chown -R fn:fn /home/fn/.ssh
 
ADD . /function/
WORKDIR /function
RUN chmod -R o+r /function

ENV PYTHONPATH=/function:/python
USER fn

ENV ORACLE_HOME='/usr/lib/oracle/19.23/client64/lib/'

ENV TNS_ADMIN='/tmp'

ENTRYPOINT ["/python/bin/fdk", "/function/func.py", "handler"]
