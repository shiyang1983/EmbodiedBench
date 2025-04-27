#!/bin/bash


source "$(conda info --base)/etc/profile.d/conda.sh"
export EMBODIED_BENCH_ROOT=$(pwd)

shopt -s expand_aliases

alias with-proxy='HTTPS_PROXY=http://fwdproxy:8080 HTTP_PROXY=http://fwdproxy:8080 FTP_PROXY=http://fwdproxy:8080 https_proxy=http://fwdproxy:8080 http_proxy=http://fwdproxy:8080 ftp_proxy=http://fwdproxy:8080 http_no_proxy='\''\'\'\''*.facebook.com|*.tfbnw.net|*.fb.com'\''\'\'




# # Environment for ```Habitat and Alfred```
with-proxy conda env create -f conda_envs/environment.yaml 
conda activate embench
with-proxy pip install -e .

# Environment for ```EB-Navigation```
with-proxy conda env create -f conda_envs/environment_eb-nav.yaml 
conda activate embench_nav
with-proxy pip install -e .

# Environment for ```EB-Manipulation```
with-proxy conda env create -f conda_envs/environment_eb-man.yaml 
conda activate embench_man
with-proxy pip install -e .

# Install Git LFS
with-proxy git lfs install
with-proxy git lfs pull

# Install EB-ALFRED
conda activate embench
with-proxy git clone https://huggingface.co/datasets/EmbodiedBench/EB-ALFRED
mv EB-ALFRED embodiedbench/envs/eb_alfred/data/json_2.1.0

# Install EB-Habitat
conda activate embench
with-proxy conda install -y habitat-sim==0.3.0 withbullet  headless -c conda-forge -c aihabitat
with-proxy git clone -b 'v0.3.0' --depth 1 https://github.com/facebookresearch/habitat-lab.git ./habitat-lab
cd ./habitat-lab
with-proxy pip install -e habitat-lab
cd ..
with-proxy conda install -y -c conda-forge git-lfs
with-proxy python -m habitat_sim.utils.datasets_download --uids rearrange_task_assets
mv data embodiedbench/envs/eb_habitat

# Install EB-Manipulation
conda activate embench_man
cd embodiedbench/envs/eb_manipulation
with-proxy wget https://downloads.coppeliarobotics.com/V4_1_0/CoppeliaSim_Pro_V4_1_0_Ubuntu20_04.tar.xz
tar -xf CoppeliaSim_Pro_V4_1_0_Ubuntu20_04.tar.xz
rm CoppeliaSim_Pro_V4_1_0_Ubuntu20_04.tar.xz
mv CoppeliaSim_Pro_V4_1_0_Ubuntu20_04/ $EMBODIED_BENCH_ROOT
export COPPELIASIM_ROOT=$EMBODIED_BENCH_ROOT/CoppeliaSim_Pro_V4_1_0_Ubuntu20_04
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$COPPELIASIM_ROOT
export QT_QPA_PLATFORM_PLUGIN_PATH=$COPPELIASIM_ROOT
with-proxy git clone https://github.com/stepjam/PyRep.git
cd PyRep
with-proxy pip install -r requirements.txt
with-proxy pip install -e .
cd ..
with-proxy pip install -r requirements.txt
with-proxy pip install -e .
cp ./simAddOnScript_PyRep.lua $COPPELIASIM_ROOT
with-proxy git clone https://huggingface.co/datasets/EmbodiedBench/EB-Manipulation
mv EB-Manipulation/data/ ./
rm -rf EB-Manipulation/
cd ../../..
