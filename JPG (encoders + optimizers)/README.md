# JPG encoders + optimizers benchmark
### Encoders
- `cjpegli` v0.10.2 e1489592 [AVX2,SSE4,SSE2]
- `guetzli` 1.0.1-4  (Arch extra repo)
- `libjpeg-turbo` version 3.0.2 (build 20240125)
- `mozjpeg` version 4.1.5 (build 20240322)

### Optimizers
- `ect` 0.9.5 compiled on Jan 13 2024 ([source](https://github.com/fhanau/Efficient-Compression-Tool/))
- `jpegultrascan.pl` 1.3.4 2021-03-24 ([source](https://encode.su/threads/2489-jpegultrascan-an-exhaustive-JPEG-scan-optimizer))

### Conclusions

"Unfortunately" optimizing the JPG does not change the encoder to choose for the best ratio bpp/ssim2. I've seen much higher size reduction for JPGs found on the Internet (up to 10%), but it is quite small with this benchmark.

It is quite safe to say "**always use cjpegli 420 for bpp < 1** (surprisingly followed really close by mozjpeg), **otherwise cjpegli 444**", jpeg-turbo indeed is fast but who can *not* bear sub-second encode time with cjpegli...

There a little exception here: the konosuba is quite an unusual image with lots of colors (and difficult to compress). For that one, the winner is `cjpegli` once again but with 444 as chroma subsampling. I love that one.

ECT optimization definitely useful and worth it, as it is almost instantaneous.\
Scans bruteforcing (`jpegultrascan.pl`) is only for people (like me) worrying about maximum compression at the cost of really slow speed - note that since it's bruteforcing, it can be done using several threads.
