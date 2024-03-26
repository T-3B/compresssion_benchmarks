#!/bin/bash

(($#)) || { echo 'Arguments of this script should be PNG files.'; exit 1;}

set -a
printf FileName,encoder,encQuality,bpp,encTimeSeconds,ssimulacra2\\n
TIMEFORMAT=%R

jpgopt() {
	local b c i=$2 k=$3 a=$4
	b=$(ssimulacra2_rs image "$i" /dev/shm/"$1"_"$i"$k.jpg)
	printf "$i",$1,$k,$(identify -format '%B*8/%h/%w\n' /dev/shm/"$1"_"$i"$k.jpg | bc -l),$a,${b#* }\\n
	c=$({ time ect -9 -progressive -quiet /dev/shm/"$1"_"$i"$k.jpg &>/dev/null;} 2>&1)
	printf "$i",$1+ECT,$k,$(identify -format '%B*8/%h/%w\n' /dev/shm/"$1"_"$i"$k.jpg | bc -l),$(bc <<<"$a+$c"),${b#* }\\n
	c=$({ time ./jpegultrascan.pl -i -q /dev/shm/"$1"_"$i"$k{,.opt}.jpg &>/dev/null;} 2>&1)
	printf "$i",$1+ultrascan,$k,$(identify -format '%B*8/%h/%w\n' /dev/shm/"$1"_"$i"$k.opt.jpg | bc -l),$(bc <<<"$a+$c"),${b#* }\\n
	rm /dev/shm/"$1"_"$i"$k{,.opt}.jpg
}

jpgli() {  # cjxl v0.10.2 e1489592 [AVX2,SSE4,SSE2]
	jpgopt cjpegli$2 "$3" $1 $({ time cjpegli "$3" /dev/shm/cjpegli$2_"$3"$1.jpg -q $1 --chroma_subsampling=$2 --quiet &>/dev/null;} 2>&1)
}

guli() {  # guetzli 1.0.1-4  (Arch extra repo)
	jpgopt guetzli "$2" $1 $({ time guetzli --nomemlimit --quality $1 "$2" /dev/shm/guetzli_"$2"$1.jpg &>/dev/null;} 2>&1)
}

turbo() {  # libjpeg-turbo version 3.0.2 (build 20240125)
	jpgopt cjpegTurbo "$2" $1 $({ ffmpeg -i "$2" /dev/shm/"$2"$1.ppm &>/dev/null; time cjpeg -quality $1 -optimize -outfile /dev/shm/cjpegTurbo_"$2"$1.jpg /dev/shm/"$2"$1.ppm &>/dev/null; rm /dev/shm/"$2"$1.ppm;} 2>&1)
}

moz() {  # mozjpeg version 4.1.5 (build 20240322)
	jpgopt mozjpeg "$2" $1 $({ time ./cjpeg -optimize -dc-scan-opt 2 -quality $1 -outfile /dev/shm/mozjpeg_"$2"$1.jpg "$2" &>/dev/null;} 2>&1)
}

parallel --bar --jl parallel.log --resume --memsuspend 3G ::: guli\ {84..100..4}		moz\ {10..100..5}		turbo\ {10..100..5}		jpgli\ {10..100..5}\ {444,440,422,420} ::: "$@" >>jpgbench.log || exit $?		
grep +ECT, jpgbench.log >>jpgbench_ect.log
grep +ultrascan, jpgbench.log >>jpgbench_ultrascan.log
grep -ve +ECT, -e +ultrascan, jpgbench.log >jpgbench2.log
mv jpgbench{2,}.log
