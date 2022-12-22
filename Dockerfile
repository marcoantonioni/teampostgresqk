FROM quay.io/marco_antonioni/teampostgres-base:latest

ENV BASE_INST=/opt
ENV INST_FOLDER=${BASE_INST}/teampostgresql

#------------------------------
# add teampostgres
RUN curl -o ${BASE_INST}/tp.zip -k -LO http://cdn.webworks.dk/download/teampostgresql_multiplatform.zip && \
    unzip ${BASE_INST}/tp.zip -d ${BASE_INST} && \
    rm ${BASE_INST}/tp.zip

#------------------------------
# add starter
ADD ./startTP.sh ${INST_FOLDER}/.

#------------------------------
# Sets the directory and file permissions to allow users in the root group 
# to access them with the same authorization as the directory and file owner
RUN chgrp -R 0 ${INST_FOLDER} && \
    chmod -R g=u ${INST_FOLDER}

CMD ["/opt/teampostgresql/startTP.sh"]
