#!/bin/bash

ENGINE="UMEM"

engine=$(echo $ENGINE | tr '[:upper:]' '[:lower:]') # make ENGINE variable lower case


sudo apt-get update -y
sudo apt-get install -y apt-utils 2>&1 | grep -v "debconf: delaying package configuration, since apt-utils is not installed"
sudo apt-get install -y --no-install-recommends cmake git libssl-dev build-essential zlib1g zlib1g-dev python3 python3-dev

git config --global http.sslVerify "false"
git clone https://github.com/unum-cloud/ukv.git && cd ./ukv

cmake -DUKV_BUILD_TESTS=0 -DUKV_BUILD_BENCHMARKS=0 -DUKV_BUILD_ENGINE_${ENGINE}=1 -DUKV_BUILD_API_FLIGHT_CLIENT=0 -DUKV_BUILD_API_FLIGHT_SERVER=1 . && make -j8 ukv_flight_server_${engine}


sudo tee /etc/systemd/system/ukv_flight_server_umem.service > /dev/null <<EOF
[Unit]
Description=UKV Flight Server UMEM Service
[Service]
ExecStart=/usr/bin/ukv_flight_server_umem
Restart=always
[Install]
WantedBy=multi-user.target
EOF
sudo mv /home/ubuntu/ukv/build/bin/ukv_flight_server_umem /usr/bin
sudo chown root:root /usr/bin/ukv_flight_server_umem
sudo systemctl daemon-reload
sudo systemctl enable ukv_flight_server_umem.service
sudo systemctl start ukv_flight_server_umem.service
else
echo "Wrong Engine"
fi
