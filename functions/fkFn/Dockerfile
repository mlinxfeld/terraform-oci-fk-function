FROM oraclelinux:8-slim as ol8

RUN microdnf install -y wget \
    tar \
    gzip \
    which 

FROM fnproject/python:3.8.5-dev as build-stage

WORKDIR /function

ADD requirements.txt /function/

RUN pip3 install --target /python/  --no-cache --no-cache-dir -r requirements.txt && \			 
    rm -fr ~/.cache/pip /tmp* requirements.txt func.yaml Dockerfile .venv

ADD . /function/

RUN rm -fr /function/.pip_cache

FROM fnproject/python:3.8.5

WORKDIR /function

COPY --from=build-stage /function /function

COPY --from=build-stage /python /python

ENV PYTHONPATH=/python

ENTRYPOINT ["/python/bin/fdk", "/function/func.py", "handler"]