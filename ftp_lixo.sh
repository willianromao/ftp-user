#!/bin/bash
#
#script para remover os arquivos temporários da pasta /tmp/ftp_lixo
#
find /tmp/ftp_lixo/* -ctime +7 -exec rm -R {} \;
exit 0
