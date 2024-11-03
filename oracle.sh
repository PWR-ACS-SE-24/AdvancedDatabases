#!/bin/env bash

docker run -d -p 1521:1521 -e ORACLE_PASSWORD=password -v oracle-volume:/opt/oracle/oradata gvenzl/oracle-xe:21.3.0
