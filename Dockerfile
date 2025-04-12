FROM judge0/judge0:1.13.1 AS judge0_builder
USER judge0
ENV USER judge0
ENV USER_HOME_DIR /home/judge0
COPY ./scripts/prepare_workers /api/scripts/prepare_workers
COPY ./scripts/workers /api/scripts/workers

# Install Julia for Computational Modeling Challenge


RUN mkdir -p /tmp/julia
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.2-linux-x86_64.tar.gz -P /tmp/julia
RUN wget https://julialang-s3.julialang.org/bin/checksums/julia-1.10.2.sha256 -P /tmp/julia
RUN echo "$(sha256sum /tmp/julia/julia-1.10.2-linux-x86_64.tar.gz)" | xargs printf '%s %s' "$1" "$2" | sha256sum --check
RUN sudo tar xfvz /tmp/julia/julia-1.10.2-linux-x86_64.tar.gz --directory /usr/local
RUN ls /usr/local/julia-1.10.2  # Provjera da postoji
RUN rm -rf /tmp/julia

ENV JULIA_DEPOT_PATH /usr/local/lib/.julia
ENV JULIA_HOME /usr/local/julia-1.10.2
ENV JULIA_EXE $JULIA_HOME/bin/julia

RUN sudo mkdir -p ${JULIA_DEPOT_PATH}
RUN sudo chown -R judge0:judge0 ${JULIA_DEPOT_PATH}
RUN $JULIA_HOME/bin/julia -e 'import Pkg; Pkg.add("FileIO")' && \
        $JULIA_HOME/bin/julia -e 'import Pkg; Pkg.add("ImageIO")' && \
        $JULIA_HOME/bin/julia -e 'import Pkg; Pkg.add("PNGFiles")' && \
        $JULIA_HOME/bin/julia -e 'import Pkg; Pkg.add("Measures")' && \
        $JULIA_HOME/bin/julia -e 'import Pkg; Pkg.add("Plots")' && \
        $JULIA_HOME/bin/julia -e 'import Pkg; Pkg.add("UUIDs")' && \
        $JULIA_HOME/bin/julia -e 'import Pkg; Pkg.instantiate()'

# Gunakan g++ versi default yang tersedia
RUN apt-get update && apt-get install -y g++

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

RUN sudo /usr/local/python-3.8.1/bin/pip3.8 install --upgrade pip && \
    sudo /usr/local/python-3.8.1/bin/pip3.8 install numpy

# Install latest JDK

RUN mkdir -p /tmp/java && mkdir -p /usr/lib/jvm

RUN wget https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_linux-x64_bin.tar.gz  -P /tmp/java
RUN wget https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_linux-x64_bin.tar.gz.sha256 -P /tmp/java
RUN echo "$(sha256sum /tmp/java/openjdk-21.0.2_linux-x64_bin.tar.gz)" | xargs printf '%s %s' "$1" "$2" | sha256sum --check
RUN sudo tar xfvz /tmp/java/openjdk-21.0.2_linux-x64_bin.tar.gz --directory /usr/lib/jvm
RUN ls /usr/lib/jvm/jdk-21.0.2 # To confirm that the directory has the jdk-21.0.2 file!
    
RUN rm /tmp/java/*

# Install local copy of Edgar library
COPY oop/edgar-oop.jar /usr/lib/jvm/edgar-libs/edgar.jar

RUN sudo /usr/local/python-3.8.1/bin/pip3.8 install --upgrade pip && \
    sudo /usr/local/python-3.8.1/bin/pip3.8 install -I PuLP==2.5.1 scipy pyomo



RUN apt-get update && apt-get install -y python3 python3-pip


# Copies the required ruby files for importing languages into the database automatically.
COPY lang_imports/edgar_langs/ /api/db/languages/edgar_langs/

RUN sudo touch /api/db/languages/edgar_langs/edg_lang_id_start.rb && \
    sudo touch /api/db/temp && \
    sudo chown -R judge0: /api
RUN echo @start = $(cat /api/db/languages/*.rb | perl -n -e '/\s*id:\s*(\d+)/ && print "$1\n"' | sort -n | tail -1) > /api/db/languages/edgar_langs/edg_lang_id_start.rb && \
    echo "require_relative 'languages/imp_edgar_langs'" | cat - /api/db/seeds.rb > /api/db/temp && mv /api/db/temp /api/db/seeds.rb

COPY lang_imports/imp_edgar_langs.rb /api/db/languages/imp_edgar_langs.rb
