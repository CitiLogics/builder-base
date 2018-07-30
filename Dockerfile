FROM ubuntu:bionic

RUN apt-get update && \
    apt-get install -y \
    libiodbc2-dev \
    libiodbc2 \
    iodbc \
    tdsodbc \
    openssl \
    libsqlite3-dev \
    curl \
    g++ \
    make \
    cmake \
    zlib1g-dev \
    zlib1g \
    libcurl4-openssl-dev \
    libssl-dev \
    git \
    llvm \
    clang

WORKDIR /opt/src

## build / install boost
ARG boost_version=1.67.0
ARG boost_dir=boost_1_67_0
ENV boost_version ${boost_version}

RUN curl -JLO http://downloads.sourceforge.net/project/boost/boost/${boost_version}/${boost_dir}.tar.gz

RUN tar xfz ${boost_dir}.tar.gz \
    && rm ${boost_dir}.tar.gz \
    && cd ${boost_dir} \
    && ./bootstrap.sh  --with-libraries=filesystem,program_options,system,serialization,iostreams\
    && ./b2 cxxflags=-fPIC --without-python --prefix=/usr -j 4 link=static runtime-link=shared install \
    && cd .. && rm -rf ${boost_dir} && ldconfig

### install cpprestsdk library
RUN git clone https://github.com/Microsoft/cpprestsdk.git casablanca \
        && cd casablanca/Release \
        && sed -e 's/ -Wcast-align//g' -i CMakeLists.txt \
        && mkdir build.release \
        && cd build.release \
        && cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=0 -DBUILD_SAMPLES=0 -DBUILD_SHARED_LIBS=0 -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        && make \
        && make install

## install sqlite_modern dep
RUN cd /opt/src \
        && git clone https://github.com/aminroosta/sqlite_modern_cpp.git \
        && cp -R sqlite_modern_cpp/hdr/* /usr/local/include/

## install cpprestsdk convenience framework
RUN curl -L -o granada.tar.gz https://github.com/webappsdk/granada/archive/1.56.0.tar.gz \
        && tar -xzf granada.tar.gz \
        && cp -R granada-1.56.0/Release/include/granada /usr/local/include

# cleanup this image
RUN cd /opt && rm -rf src
WORKDIR /opt
