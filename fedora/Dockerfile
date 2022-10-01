FROM fedora:36

RUN dnf install -y \
autoconf \
g++ \
gcc-aarch64-linux-gnu \
git \
iasl \
libuuid-devel \
nasm \
python \
uuid-c++ \
;

WORKDIR /root
RUN git clone --branch edk2-stable202208 --depth 1 https://github.com/tianocore/edk2.git \
&&  cd edk2 \
&&  git submodule update --init --recursive \
;

RUN cd edk2 \
&&  make -C BaseTools \
&&  source ./edksetup.sh \
&&  build -p ArmVirtPkg/ArmVirtQemu.dsc -a AARCH64 -b RELEASE -t GCC5 \
;

RUN cp edk2/Build/ArmVirtQemu-AARCH64/RELEASE_GCC5/FV/QEMU_EFI.fd uefi.fd \
&&  dd if=/dev/zero of=uefi.img bs=1M count=64 \
&&  dd if=uefi.fd of=uefi.img conv=notrunc \
;
