FROM ubuntu:18.04

RUN useradd -ms /bin/bash sega

WORKDIR /home/sega

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y binutils-m68k-linux-gnu binutils-z80 cmake python python-pil && \
  rm -rf /var/lib/apt/lists/*

# RUN apt-get install -y texinfo libncurses5-dev

# ADD http://ftp.gnu.org/gnu/gdb/gdb-8.2.tar.xz /home/sega/gdb/
COPY entrypoint.sh ./
# TODO: Copy the tools directory
# TODO: Run as a user with the same uid/gid as the host user. See:
# https://stackoverflow.com/questions/44683119/dockerfile-replicate-the-host-user-uid-and-gid-to-the-image
# for a couple of approaches.
RUN chmod a+x entrypoint.sh
USER sega

ENTRYPOINT ["./entrypoint.sh"]
# CMD ["/bin/bash"]
