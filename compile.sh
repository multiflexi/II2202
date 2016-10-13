sudo apt install cmake mercurial autoconf automake build-essential libass-dev libfreetype6-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev nasm libfdk-aac-dev libmp3lame-dev libopus-dev git yasm unzip wget sysstat libxvidcore-dev libfaac-dev libopencore-amrnb-dev libopencore-amrwb-dev libgsm1-dev zlib1g-dev libgpac1-dev
mkdir ~/ffmpeg_sources
cd ~/ffmpeg_sources
git clone https://github.com/cisco/openh264
cd openh264
make ARCH=x86_64 && sudo make install
cd ~/ffmpeg_sources
wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar xzvf yasm-1.3.0.tar.gz
cd yasm-1.3.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
make install
make distclean
cd ~/ffmpeg_sources
wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
tar xjvf last_x264.tar.bz2
cd x264-snapshot*
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
PATH="$HOME/bin:$PATH" make
make install
make distclean
cd ~/ffmpeg_sources
hg clone https://bitbucket.org/multicoreware/x265
cd ~/ffmpeg_sources/x265/build/linux
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
make
make install
make distclean
cd ~/ffmpeg_sources
git clone https://chromium.googlesource.com/webm/libvpx
cd libvpx*
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp8 --enable-vp9
PATH="$HOME/bin:$PATH" make
make install
make clean
cd ~/ffmpeg_sources
wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-opencl \
  --enable-nvenc \
  --enable-nvresize \
  --extra-cflags=-I../cudautils \
  --extra-ldflags=-L../cudautils \
  --enable-libmfx \
  --enable-libxvid \
  --enable-libopenh264 \
  --enable-libgsm \
  --enable-libopencore-amrnb \	
  --enable-nonfree
PATH="$HOME/bin:$PATH" make
make install
make distclean
hash -r

