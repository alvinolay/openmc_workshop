# OUTDATED
# This script installs Miniconda, Python, CadQuery, NJOY, MOAB, DAGMC, OpenMC, Trelis, DAGMC-Trelis plugin, nuclear data

sudo apt-get --yes update && sudo apt-get --yes upgrade 

sudo apt-get install --yes wget

# Miniconda

# wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.8.3-Linux-x86_64.sh
# bash Miniconda3-py37_4.8.3-Linux-x86_64.sh
# conda init
# conda create -y --name cq
# conda activate cq
# conda clean --all
# conda install -c conda-forge -c python python=3.7.8
# conda clean --all
# conda install -c conda-forge -c cadquery cadquery=2

sudo apt-get --yes install gfortran 
sudo apt-get --yes install g++
sudo apt-get --yes install libhdf5-dev

sudo apt-get install -y python3
sudo apt-get install -y python3-pip
sudo apt-get install -y python3-dev
sudo apt-get install -y python3-tk

sudo apt-get install --yes imagemagick
sudo apt-get install --yes hdf5-tools
sudo apt-get install --yes paraview
sudo apt-get install --yes eog
sudo apt-get install --yes libsilo-dev
sudo apt-get install --yes git

sudo apt-get --yes install dpkg
sudo apt-get --yes install libxkbfile1
sudo apt-get --yes install -f
sudo apt-get --yes install libblas-dev 
sudo apt-get --yes install liblapack-dev

sudo apt-get install libeigen3-dev

sudo apt-get --yes install libnetcdf-dev
sudo apt-get --yes install libnetcdf13

pip3 install cmake
echo "export PATH=$PATH:$HOME/.local/bin" >> ~/.bashrc

pip3 install numpy pandas six h5py Matplotlib uncertainties lxml scipy cython vtk pytest
pip3 install codecov pytest-cov pylint plotly tqdm pyside2 ghalton==0.6.1

pip3 install neutronics_material_maker

cd ~
git clone https://github.com/njoy/NJOY2016
cd NJOY2016
mkdir build
cd build
cmake -Dstatic=on .. && make 2>/dev/null
sudo make install

MOAB_INSTALL_DIR=$HOME/MOAB
DAGMC_INSTALL_DIR=$HOME/DAGMC
set -ex

echo "export MOAB_INSTALL_DIR=$HOME/MOAB" >> ~/.bashrc 
echo "export DAGMC_INSTALL_DIR=$HOME/DAGMC" >> ~/.bashrc

pip3 install cython

cd ~
mkdir MOAB
cd MOAB
git clone -b Version5.1.0 https://bitbucket.org/fathomteam/moab/
mkdir build
cd build
# this installs without netcdf but with pymoab
#cmake ../moab -DENABLE_HDF5=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$MOAB_INSTALL_DIR -DENABLE_PYMOAB=ON
# this installs with netcdf but without pymoab
cmake ../moab -DENABLE_HDF5=ON -DENABLE_MPI=off -DENABLE_NETCDF=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$MOAB_INSTALL_DIR
make -j2 
make -j2 install
# this 2nd build is required which is a shame
# this is to be used if you want pymoab
# cmake ../moab -DBUILD_SHARED_LIBS=OFF
# otherwise if you want netcdf
cmake ../moab -DBUILD_SHARED_LIBS=OFF
make -j2 install

echo "export LD_LIBRARY_PATH=$MOAB_INSTALL_DIR/lib:$LD_LIBRARY_PATH" >> ~/.bashrc
echo "export PATH=$PATH:$MOAB_INSTALL_DIR/bin" >> ~/.bashrc

cd ~
mkdir DAGMC
cd DAGMC 
git clone -b develop https://github.com/svalinn/DAGMC.git
mkdir build
cd build
cmake ../DAGMC -DBUILD_TALLY=ON -DCMAKE_INSTALL_PREFIX=$DAGMC_INSTALL_DIR -DMOAB_DIR=$MOAB_INSTALL_DIR
make -j2 install

echo "export LD_LIBRARY_PATH=$DAGMC_INSTALL_DIR/lib:$LD_LIBRARY_PATH" >> ~/.bashrc

# OpenMC Install, this must be installed to /opt/openmc, `parametric_plasma_source` python module has this path hard-coded
cd /opt
sudo git clone --recurse-submodules https://github.com/openmc-dev/openmc.git
cd /opt/openmc
sudo chmod 777 -R openmc
sudo git checkout develop
sudo mkdir build
sudo chmod 777 build
cd build
cmake -Ddagmc=ON -DCMAKE_PREFIX_PATH=$DAGMC_INSTALL_DIR ..
# cmake -Ddagmc=ON -Ddebug=on -DDAGMC_ROOT=$DAGMC_INSTALL_DIR ..
sudo make -j2
sudo make -j2 install
cd /opt
sudo chmod 777 -R openmc
cd /opt/openmc/
pip3 install -e .

cd ~
git clone https://github.com/openmc-dev/data.git
cd data
python3 convert_fendl.py
python3 convert_tendl.py
python3 convert_nndc71.py

OPENMC_CROSS_SECTIONS_NNDC=~/data/nndc-b7.1-hdf5/cross_sections.xml
echo "export OPENMC_CROSS_SECTIONS_NNDC=~/data/nndc-b7.1-hdf5/cross_sections.xml" >> ~/.bashrc
OPENMC_CROSS_SECTIONS_TENDL=~/data/tendl-2017-hdf5/cross_sections.xml
echo "export OPENMC_CROSS_SECTIONS_TENDL=~/data/tendl-2019-hdf5/cross_sections.xml" >> ~/.bashrc
OPENMC_CROSS_SECTIONS_FENDL=~/data/fendl-3.1d-hdf5/cross_sections.xml
echo "export OPENMC_CROSS_SECTIONS_FENDL=~/data/fendl-3.1d-hdf5/cross_sections.xml" >> ~/.bashrc


# OPENMC_CROSS_SECTION library

# Single cross-section library

# change filepaths to desired library cross_sections.xml file
OPENMC_CROSS_SECTIONS=~/data/nndc-b7.1-hdf5/cross_sections.xml
echo "export OPENMC_CROSS_SECTIONS=~/data/nndc-b7.1-hdf5/cross_sections.xml" >> ~/.bashrc

# Combined cross-section library

# cd ~/data
# python3 combine_libraries.py -l fendl-3.1d-hdf5/cross_sections.xml nndc-b7.1-hdf5/cross_sections.xml tendl-2019-hdf5/cross_sections.xml -o combined_cross_sections.xml
# OPENMC_CROSS_SECTIONS=~/data/combined_cross_sections.xml
# echo 'export OPENMC_CROSS_SECTIONS=~/data/combined_cross_sections.xml' >> ~/.bashrc


# Trelis

# Download Trelis-16.5.4-Lin64.deb
# Add Trelis-16.5.4-Lin64.deb to /opt folder

# cd /opt
# sudo dpkg -i Trelis-16.5.4-Lin64.deb


# Trelis-DAGMC Plugin

cd ~
sudo apt-get install openfortivpn
sudo apt install curl

# Download svalinn-plugin-16.5-u18.04.tgz from https://uwmadison.app.box.com/v/dagmc-trelis
# Add svalinn-plugin-16.5-u18.04.tgz to /opt/Trelis-16.5/bin/plugins

cd /opt/Trelis-16.5/bin/plugins
sudo tar xzf svalinn-plugin-16.5-u18.04.tgz

cd /opt/Trelis-16.5/bin
sudo bash plugins/svalinn/install.sh

PATH=$PATH:/opt/Trelis-16.5/bin
echo "export PATH=$PATH:/opt/Trelis-16.5/bin" >> ~/.bashrc

LD_LIBRARY_PATH=/opt/Trelis-16.5/bin/plugins/svalinn:$LD_LIBRARY_PATH
echo "export LD_LIBRARY_PATH=/opt/Trelis-16.5/bin/plugins/svalinn:$LD_LIBRARY_PATH" >> ~/.bashrc
