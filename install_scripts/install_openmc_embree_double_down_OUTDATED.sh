# OUTDATED
# This script installs Miniconda, CadQuery, NJOY, MOAB, Embree, Double-Down, DAGMC, OpenMC, Nuclear Data.


sudo apt-get --yes update && sudo apt-get --yes upgrade 

# Install dependencies from Debian package manager
sudo apt-get install --yes wget \
    git \
    gfortran \
    g++ \
    cmake \
    mpich \
    libmpich-dev \
    libhdf5-serial-dev \
    libhdf5-mpich-dev \
    imagemagick \
    autoremove \
    clean

# Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.8.3-Linux-x86_64.sh
bash Miniconda3-py37_4.8.3-Linux-x86_64.sh
conda init
conda create -y --name cq
conda activate cq
conda clean --all
conda install -c conda-forge -c cadquery cadquery=master
conda install gxx_linux-64

# required pacakges identified from openmc travis.yml
sudo apt-get --yes install mpich \
    libmpich-dev \
    libhdf5-serial-dev \
    libhdf5-mpich-dev \
    libblas-dev \
    liblapack-dev \
    imagemagick

# needed to allow NETCDF on MOAB which helps with tet meshes in OpenMC
sudo apt-get --yes install libnetcdf-dev

# eigen3 needed for DAGMC
sudo apt-get --yes install libeigen3-dev

# dependancies used in the workshop
sudo apt-get -y install git
sudo apt-get --yes install hdf5-tools

# new version needed for openmc compile
pip install cmake


# Python libraries used in the workshop
pip install plotly tqdm ghalton==0.6.1 noisyopt scikit-optimize \
            inference-tools adaptive vtk itkwidgets nest_asyncio \
            neutronics_material_maker parametric-plasma-source pytest \
            pytest-cov

# needed for moab
pip install cython

# needed for openmc
pip install --upgrade numpy


# install addition packages required for DAGMC
sudo apt-get --yes install libeigen3-dev \
    libblas-dev \
    liblapack-dev \
    libnetcdf-dev \
    libtbb-dev \
    libglfw3-dev

# needed for CadQuery functionality
sudo apt-get install -y libgl1-mesa-glx libgl1-mesa-dev libglu1-mesa-dev \
                       freeglut3-dev libosmesa6 libosmesa6-dev \
                       libgles2-mesa-dev


export compile_cores=2

# Clone and install Embree
git clone --single-branch --branch master https://github.com/embree/embree
cd embree
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=.. \
    -DEMBREE_ISPC_SUPPORT=OFF
make -j"$compile_cores"
make -j"$compile_cores" install


cd ~
mkdir MOAB
cd MOAB
git clone  --single-branch --branch develop https://bitbucket.org/fathomteam/moab/
mkdir build
cd build
# this installs without netcdf but with pymoab
#cmake ../moab -DENABLE_HDF5=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$MOAB_INSTALL_DIR -DENABLE_PYMOAB=ON
cmake ../moab -DENABLE_HDF5=ON \
    -DENABLE_NETCDF=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DENABLE_FORTRAN=OFF \
    -DCMAKE_INSTALL_PREFIX=$HOME/MOAB
make -j"$compile_cores" 
make -j"$compile_cores" install
# this 2nd build is required and includes pymoab
cmake ../moab -DBUILD_SHARED_LIBS=ON \
    -DENABLE_HDF5=ON \
    -DENABLE_PYMOAB=ON \
    -DENABLE_BLASLAPACK=OFF \
    -DENABLE_FORTRAN=OFF \
    -DCMAKE_INSTALL_PREFIX=$HOME/MOAB
make -j"$compile_cores"
make -j"$compile_cores" install
cd pymoab
bash install.sh
python setup.py install

# Clone and install Double-Down
cd ~
git clone https://github.com/pshriwise/double-down
cd double-down
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=.. \
    -DMOAB_DIR=$HOME/MOAB \
    -DEMBREE_DIR=$HOME/embree/lib/cmake/embree-3.12.1
make -j"$compile_cores"
make -j"$compile_cores" install

# DAGMC install
cd ~
mkdir DAGMC
cd DAGMC
git clone --single-branch --branch develop https://github.com/svalinn/DAGMC.git
mkdir build
cd build
cmake ../DAGMC -DBUILD_TALLY=ON \
    -DCMAKE_INSTALL_PREFIX=$HOME/DAGMC \
    -DMOAB_DIR=$HOME/MOAB \
    -DDOUBLE_DOWN=ON \
    -DCMAKE_PREFIX_PATH=$HOME/double-down/lib \
    -DDOUBLE_DOWN_DIR=$HOME/double-down/
    
make -j"$compile_cores" install

export DAGMC_INSTALL_DIR=$HOME/DAGMC
export LD_LIBRARY_PATH=$DAGMC_INSTALL_DIR/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/opt/Trelis-16.5/bin/plugins/svalinn:$LD_LIBRARY_PATH

# installs OpenMC from source
cd /opt
git clone --recurse-submodules https://github.com/openmc-dev/openmc.git
sudo chmod -R 777 openmc
cd openmc
mkdir build
cd build
cmake -Ddagmc=ON \
    -DCMAKE_PREFIX_PATH=$HOME/DAGMC/ \
    -DHDF5_PREFER_PARALLEL=OFF .. 
make -j"$compile_cores"
sudo make -j"$compile_cores" install 
cd /opt/openmc/
pip install .

# Clone and install NJOY2016
cd ~
git clone https://github.com/njoy/NJOY2016 --branch master --single-branch
cd NJOY2016
mkdir build
cd build
cmake -Dstatic=on .. 
make 2>/dev/null
sudo make install

# clone and download nuclear data
git clone --single-branch --branch master https://github.com/openmc-dev/data.git
python data/convert_nndc71.py
python data/convert_tendl.py
python data/data/combine_libraries.py -l data/nndc-b7.1-hdf5/cross_sections.xml data/tendl-2019-hdf5/cross_sections.xml -o data/cross_sections.xml
OPENMC_CROSS_SECTIONS=~/data/cross_sections.xml
echo "export OPENMC_CROSS_SECTIONS=~/data/cross_sections.xml" >> ~/.bashrc
