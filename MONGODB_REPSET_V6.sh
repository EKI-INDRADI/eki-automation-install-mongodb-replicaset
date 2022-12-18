#!/bin/bash -ex

# DESCRIPTION : AUTO INSTALL MONGODB
# MAINTENER : EKI INDRADI
# OS : UBUNTU 20.04 LTS
# TESTED : 2022-12-18
# GITHUB : https://github.com/EKI-INDRADI
# SERVICE : AWS EC2, AWS LIGHTSAIL, VPS SERVER
#
#
# mkdir -p /home/ubuntu && cd /home/ubuntu && rm -rf MONGODB_REPSET_V6 && nano MONGODB_REPSET_V6
# chmod u+x MONGODB_REPSET_V6 && ./MONGODB_REPSET_V6

# Note : arbiter ga boleh 512mb


# ----------------------------------


# curl 'https://api.ipify.org?format=json'
# PRODUCT2-SNBX-DB-PRIMARY (Singapore Zone B) 16GB
# PRODUCT2-SNBX-DB-PRIMARY-IP ls.prod.db-pri.port.web.id  / 192.168.18.13
# PRODUCT2-SNBX-DB-SECONDARY (Singapore Zone B) 16GB
# PRODUCT2-SNBX-DB-SECONDARY-IP ls.prod.db-sec.port.web.id / 192.168.18.14
# PRODUCT2-SNBX-DB-ARBITER (Singapore Zone B) 2GB
# PRODUCT2-SNBX-DB-ARBITER-IP ls.prod.db-arb.port.web.id / 192.168.18.15

# PRIMARY : mongodb://UNDEFINED:UNDEFINED*1234@ls.prod.db-pri.port.web.id:6000?authSource=admin
# SECONDARY : mongodb://UNDEFINED:UNDEFINED*1234@ls.prod.db-sec.port.web.id:6000?authSource=admin
# ARBITER : mongodb://UNDEFINED:UNDEFINED*1234@ls.prod.db-arb.port.web.id:6000?authSource=admin

# mongodb://UNDEFINED:UNDEFINED*1234@ls.prod.db-pri.port.web.id:6000,ls.prod.db-sec.port.web.id:6000?authSource=admin&replicaSet=UNDEFINED-REPSET


# PRIMARY : mongodb://UNDEFINED:UNDEFINED*1234@192.168.18.13:6000?authSource=admin

# ///////////////////////////////////////////////// PRIMARY ONLY ///////////////////////////////////////////////// 

# sudo -i 
# docker exec -u 0 -it UNDEFINED_DB_6000 bash
# ------------------------------V4.4
# mongo admin -u "UNDEFINED" -p "UNDEFINED*1234"
# ------------------------------V4.4
# ------------------------------V5 +
# mongosh admin -u "UNDEFINED" -p "UNDEFINED*1234"
# ------------------------------V5 +
# use admin
# db.runCommand("getCmdLineOpts")
# db.getSiblingDB('local').system.replset.findOne()
# admin> config = { _id: 'UNDEFINED-REPSET', members: [ { _id: 0, host: 'ls.prod.db-pri.port.web.id:6000' }, { _id: 1, host: 'ls.prod.db-sec.port.web.id:6000' }, { _id: 2, host: 'ls.prod.db-arb.port.web.id:6000', arbiterOnly: true } ] }
# or
# block JSON CTRL+K+U  & CTRL+K+C
# admin> config = {
#     _id: 'UNDEFINED-REPSET',
#     members: [
#         {
#             _id: 0,
#             host: 'ls.prod.db-pri.port.web.id:6000'
#         },
#         {
#             _id: 1,
#             host: 'ls.prod.db-sec.port.web.id:6000'
#         },
#         {
#             _id: 2,
#             host: 'ls.prod.db-arb.port.web.id:6000',
#             arbiterOnly: true
#         }
#     ]
# }
# rs.initiate(config)
# rs.reconfig(config, {force: true})
# rs.status()


# ///////////////////////////////////////////////// PRIMARY ONLY ///////////////////////////////////////////////// 




# docker container logs "UNDEFINED_DB_6000"
# docker container inspect "UNDEFINED_DB_6000"

# admin> rs.initiate(config)
# { ok: 1 }
# UNDEFINED-REPSET [direct: other] admin> rs.reconfig(config, {force: true})
# { ok: 1 }



# ----------------------------------


function MongodbPrepareStage {

# -------------------------- ENV
USER_DEPLOY="ubuntu" # "ubuntu" / "crypt" / "root"
DOCKER_NAME="MONGODB_V6.0"
DOCKER_FILE="DOCKER_FILE/${DOCKER_NAME}"

MONGODB_USERNAME="UNDEFINED"
MONGODB_PASSWORD="UNDEFINED*1234"
MONGODB_PORT=6000

MONGODB_DOCKER_IMAGE_REGISTRY="mongo:6.0.1-focal"
MONGODB_KEY_FILE="DBUNDEFINED20221216"
MONGODB_REPLICA_SET_NAME="UNDEFINED-REPSET"
# -------------------------- ENV

MONGODB_DOCKER_CONTAINER_NAME="UNDEFINED_DB_${MONGODB_PORT}"
# MONGODB_PRIMARY_IP="ls.prod.db-pri.port.web.id"
# MONGODB_SECONDARY_IP="ls.prod.db-sec.port.web.id" 
# MONGODB_ARBITER_IP="ls.prod.db-arb.port.web.id"


CLEAR_DATA=1
SETUP_INIT_ONLY=0





}

function MongodbConfigureStage {

echo "=============================================== 1. MongodbConfigureStage =============================================== "


{ # try
sudo -i << EOF
docker container stop ${MONGODB_DOCKER_CONTAINER_NAME} && \
echo "=============================================== CONTAINER STOP ${MONGODB_DOCKER_CONTAINER_NAME} =============================================== "
EOF
} || { # catch
echo "=============================================== SKIP CONTAINER NOT FOUND STOP ${MONGODB_DOCKER_CONTAINER_NAME} =============================================== "
}

{ # try
sudo -i << EOF
docker container rm ${MONGODB_DOCKER_CONTAINER_NAME} && \
echo "=============================================== CONTAINER RM ${MONGODB_DOCKER_CONTAINER_NAME} =============================================== "
EOF
} || { # catch
echo "=============================================== SKIP CONTAINER NOT FOUND RM ${MONGODB_DOCKER_CONTAINER_NAME} =============================================== "
}


if [[ $CLEAR_DATA -eq 1 ]]
then
sudo -i << EOF
rm -rf /home/${USER_DEPLOY}/${DOCKER_FILE} && \
rm -rf /home/${USER_DEPLOY}/${DOCKER_FILE}/UNDEFINED_DB_data_key/keyFile && \
rm -rf /home/${USER_DEPLOY}/${DOCKER_FILE}/UNDEFINED_DB_data/*
EOF
fi

sudo -u ${USER_DEPLOY} sh -c "
mkdir -p /home/${USER_DEPLOY}/${DOCKER_FILE}/UNDEFINED_DB_data && \
mkdir -p /home/${USER_DEPLOY}/${DOCKER_FILE}/UNDEFINED_DB_data_key
"
sudo -i << EOF
docker pull "${MONGODB_DOCKER_IMAGE_REGISTRY}" && \
sleep 5 && \
chmod 777 -Rv /home/${USER_DEPLOY}/${DOCKER_FILE}/UNDEFINED_DB_data
EOF

sudo -i << EOF
cd /home/${USER_DEPLOY}/${DOCKER_FILE}/UNDEFINED_DB_data_key && \
echo "${MONGODB_KEY_FILE}"> keyFile && \
chmod 400 keyFile && \
chown 999:999 keyFile && \
echo "=============================================== keyFile : ===============================================" && \
cat /home/${USER_DEPLOY}/${DOCKER_FILE}/UNDEFINED_DB_data_key/keyFile  && \
echo "=============================================== /keyFile : ==============================================="
EOF



}

function MongodbInstallStage {

echo "=============================================== 2. MongodbInstallStage =============================================== "

# ------------------ V2 REPSET
sudo -i << EOF
docker container create --name ${MONGODB_DOCKER_CONTAINER_NAME} \
--restart=always \
-it  \
-p "${MONGODB_PORT}:27017" \
-v "/home/${USER_DEPLOY}/${DOCKER_FILE}/UNDEFINED_DB_data:/data/db" \
-v "/home/${USER_DEPLOY}/${DOCKER_FILE}/UNDEFINED_DB_data_key:/data/key" \
-e "MONGO_INITDB_ROOT_USERNAME=${MONGODB_USERNAME}" \
-e "MONGO_INITDB_ROOT_PASSWORD=${MONGODB_PASSWORD}" \
"${MONGODB_DOCKER_IMAGE_REGISTRY}" \
mongod --replSet "${MONGODB_REPLICA_SET_NAME}" --keyFile "/data/key/keyFile"
EOF
# ------------------ /V2 REPSET


# ------------------ V2 SINGLE
# sudo -i << EOF
# docker container create --name ${MONGODB_DOCKER_CONTAINER_NAME} \
# --restart=always \
# -it  \
# -p "${MONGODB_PORT}:27017" \
# -v "/home/${USER_DEPLOY}/${DOCKER_FILE}/UNDEFINED_DB_data:/data/db" \
# -e "MONGO_INITDB_ROOT_USERNAME=${MONGODB_USERNAME}" \
# -e "MONGO_INITDB_ROOT_PASSWORD=${MONGODB_PASSWORD}" \
# "${MONGODB_DOCKER_IMAGE_REGISTRY}"
# EOF
# ------------------ /V2 SINGLE



sudo -i << EOF
sleep 6 && \
docker container start "${MONGODB_DOCKER_CONTAINER_NAME}" && \
docker container ls
EOF


}


function MongodbSetup {


#DONT USE SETUP_INIT_ONLY
if [[ $SETUP_INIT_ONLY -eq 1 ]]
then

MongodbPrepareStage  

#&& \

# config = {
# _id: 'UNDEFINED-REPSET', 
# members: [
#         {
#             _id: 0, 
#             host: '${MONGODB_PRIMARY_IP:${MONGODB_PORT}',  
#             priority: 1
#         },
#         {
#             _id: 1, 
#             host: '${MONGODB_SECONDARY_IP }:${MONGODB_PORT}',  
#             priority: 2
#         },
#         {
#             _id: 2,
#             host: '${MONGODB_ARBITER_IP}:${MONGODB_PORT}', 
#             arbiterOnly: true, 
#             priority: 0
#         }
#     ]
# }

#------------- GAK BISA AUTO
# sudo -i << EOF 
# docker exec -u 0 -it ${MONGODB_DOCKER_CONTAINER_NAME} bash && \
# mongosh admin -u ${MONGODB_USERNAME} -p ${MONGODB_PASSWORD} && \
# use admin && \
# db.runCommand("getCmdLineOpts") && \
# db.getSiblingDB('local').system.replset.findOne() && \
# config = {_id: 'UNDEFINED-REPSET', members: [ {_id: 0, host: '${MONGODB_PRIMARY_IP }:${MONGODB_PORT }',  priority: 1 }, {_id: 1, host: '${MONGODB_SECONDARY_IP }:${MONGODB_PORT }',  priority: 2 }, {_id: 2,host: '${MONGODB_ARBITER_IP }:${MONGODB_PORT }', arbiterOnly: true, priority: 0 } ] } && \
# rs.initiate(config) && \
# rs.reconfig(config, {force: true})
# EOF
#------------- GAK BISA AUTO


sudo -i << EOF
docker container restart ${MONGODB_DOCKER_CONTAINER_NAME}
EOF

fi

if [[ $SETUP_INIT_ONLY -eq 0 ]]
then

MongodbPrepareStage  && MongodbConfigureStage && MongodbInstallStage


fi





}



MongodbSetup



