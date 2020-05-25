# poyo-v
poyo-vはFPGAやASICに使えるRISC-Vソフトプロセッサです。RV32Iの一通りの命令を実行可能な3段パイプラインインオーダプロセッサになっています。

## Running poyo-v on an FPGA
### 動作環境
- OS: Windows10 or Ubuntu18.04
- Vivado: 2018.3
- FPGAボード: [ZYBO Z7-10](http://akizukidenshi.com/catalog/g/gM-12552/)等（[ZYBO Z7-20](http://akizukidenshi.com/catalog/g/gM-12553/), [PYNQ-Z1](http://akizukidenshi.com/catalog/g/gM-13812/), [CMOD S7](http://akizukidenshi.com/catalog/g/gM-13487/)でも動作確認済。近年のXilinx社製FPGA搭載ボードであればだいたいどれでも動作可能と思われます。poyo-vは特定のIPに依存しないよう基本的に全てのモジュールがVerilog HDLのソースによって記述されています。）
- USB-シリアル変換モジュール: [FT232RL](http://akizukidenshi.com/catalog/g/gK-01977/)等

poyo-vをFPGA上で動かすためには、以下のような手順が必要です。

### 1. 本リポジトリをクローン
このリポジトリをローカルに持ってきます。
```
$ git clone https://github.com/ourfool/poyo-v.git
```

### 2. Vivadoへのファイル読み込み
新規プロジェクトを作成し、リポジトリ内の、`src/pipeline_3stage/design/`以下のファイルをソースとして、`poyo-v/src/pipeline_3stage/constraint/`以下を制約ファイルとして読み込みます。ここで制約ファイルは[CMOD S7](http://akizukidenshi.com/catalog/g/gM-13487/)向けのものになっているので、他のFPGAボードを利用する場合は合わせて各端子名を修正する必要があります。

### 3. ブロックデザインでのクロックモジュール生成
適切な周波数のクロックを生成するためVivadoのブロックデザインを利用してクロックモジュールを生成します。
具体的な手順としては、Vivado上の「Flow Navigator」 の 「IP INTEGRATOR」→「Create Block Design」を選択します。ウィンドウ上の+ボタンを押して、追加したいIPコアを検索すると、Clocking Wizardが見つかります。Clocking Wizardを追加したのちウィンドウに表示されたブロック図をダブルクリックすると、種々の設定をおこなうことができます。「Output Clocks」を選択し、「Output Freq」を変更すると、入力したクロック信号の周波数が所望の値に変化して出力されます。作成済みのCPUモジュールと組み合わせるには、「Sources」内に表示されたモジュールの名前を右クリックし、「Add module to Block Design」を選択します。するとBlock Designのウィンドウ上にモジュールが現れます。モジュールの各ポートをクリックすることで、モジュール同士を接続する線が引けます。また、FPGA外部に信号を入出力するためのportは、ウィンドウ上で右クリックしてCreate Portとすると生成できます。Clocking wizardとトップモジュールとを組み合わせ終わったら、Design Sources 内に表示されているBlock Design の名前を右クリックしCreate HDL Wrapperを選択します。確認のウィンドウでOKを押すと、HDLで書かれたラッパーが生成されます。
　最終的なFPGAへの書き込みの際には、このラッパーHDLを論理合成・配置配線していくことになります。ここで、論理合成・配置配線に用いるソースは太字で表示されています。HDLの名前を右クリックして、「Set as Top」を選択すると、名前が太字に変わり合成出来るようになります。最終的なファイル構成やブロックデザインの概形例を図に示します。

### 4. メモリデータパスの書き換え
RISC-Vプロセッサのメモリに読み込む.hexファイルのパスを環境に合わせて修正します。修正する箇所は、`define.vh`内の`define MEM_DATA_PATH "D:/Github/poyo-v/software/Coremark_RV32I_45MHz/"`です。ローカル環境に合わせて
`"D:/Github/poyo-v/software/Coremark_RV32I_45MHz/"`の場所を絶対パスで記述し直してください。

### 5. Bitstream生成・書き込み
各ファイルの修正完了後に、作成したVivadoプロジェクト上で、左端の**Flow Navigator**から**PROGRAM AND DEBUG**→**Generate Bitstream**を選択してBitstreamを生成します。完了したらPCとFPGAボードとを接続し、**Open Hardware Manager**から**Program device**を選択してFPGAボードへと書き込みます。

### 6. 動作確認
サンプルプログラムは組み込み向けベンチマークの[Coremark](https://www.eembc.org/coremark/)です。`const.xdc`内で指定されたUART用端子とGND端子とをUSB-シリアル変換モジュールのRX端子とGND端子へそれぞれ接続し、PCへUSBケーブルを介してつなぐことで、UART出力をPC上のシリアルターミナルソフト（Teraterm、gtkterm、Arduino IDE付属のターミナル等）で確認することができます。シリアルターミナルソフトのbaudrateは115200に設定してください。

<img src="https://ourfool.github.io/poyo-v/figs/poyo-v.jpg" width="600px">

各接続とターミナルソフトの設定を完了したら、動作確認をおこなうことができます。`const.xdc`内で指定されたリセットボタンを押すとプログラムが開始し、10秒ほどでシリアルターミナル上に完了のメッセージが表示されます。

<img src="https://ourfool.github.io/poyo-v/figs/poyo-v.png" width="600px">

## Creating an executable program file
poyo-v上で動作するプログラムを作るためには、以下のような手順が必要です。

### 1. コンパイラツールチェーンの用意
RISC-V RV32I向けの実行ファイルを生成するソフトウェアツールチェーンを用意します。gccの場合は[公式リポジトリ](https://github.com/riscv/riscv-gnu-toolchain)から導入することができます。これを利用することで、C言語で記述したコードをコンパイルしてRISC-V向けの実行ファイルを生成することができます。以降にクロスコンパイル環境を整えるための一連の作業を書いていきます。なお、開発環境としてはWSL（Windows Subsystem for Linux）、またはその他の仮想環境上でのUbuntuの利用を想定しています。

まずは、ツールチェーンをビルドするために必要な各種パッケージを入手します。下記のようなコマンドで各種パッケージをインストールします。

```
$ sudo apt update
$ sudo apt install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
```

続いて、公式のクロスコンパイラのリポジトリをクローンします。

```
$ git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
```

クローン作業が完了したら、リポジトリ内へと移動してツールチェーンのビルド作業をおこないます。下記のようなコマンドを打つことでビルドできます。ここで、--prefix=/opt/riscvによってツールチェーンのインストール先を指定し、--with-arch=rv32gcによってRV32Iを含むRV32GC向けのクロスコンパイラを作ることを命じています。--with-abi=ilp32では浮動小数点演算はハードウェア側でサポートしない前提であることを伝えています。インストール先については変更しても問題ありません。ビルド時間は実行環境のコア数に合わせてmakeコマンド時に-jオプションを指定することで短縮できるかもしれません。

```
$ cd riscv-gnu-toolchain/
$ ./configure --prefix=/opt/riscv --with-arch=rv32gc --with-abi=ilp32
$ sudo make
```

問題が無ければ1時間程度で完了します。成功していれば下記のコマンドに応じて

```
$ /opt/riscv/bin/riscv32-unknown-elf-gcc --version
riscv32-unknown-elf-gcc (GCC) 9.2.0
Copyright (C) 2019 Free Software Foundation, Inc.
This is free software; see the source for copying conditions. There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

のように表示されます。インストール先を変更した場合、/opt/riscvの部分は異なります。クロスコンパイラ自体も随時開発が進められているため、最新版に問題が生じる場合もあるかもしれません。その場合はクローン作業の代わりに、リポジトリのリリースページ（https://github.com/riscv/riscv-gnu-toolchain/releases）から既にリリースされているバージョン（2019年8月現在では、「v20180629」が最新リリース）のソースをダウンロードして使います。

### 2. Make
クロスコンパイラによって実行ファイルを生成し、そこからobjcopy等を利用して.bin形式のファイルを生成します、続いてこれを.hex形式へ変換し、命令メモリと4つのデータメモリ向けに分割することによって最終的に読み込む.hexファイルが揃います。この作業をまとめたMakeファイルが`software/test/
Makefile`として用意されています。

Makefileと同一の階層にC言語で記述されたコード（デフォルトではtest.cという名前に設定する。変更の場合は合わせてMakefile修正が必要）を用意し、

```
$ make
```

とすればメモリへ読み込み可能な各種.hexファイルが生成されます。

### A. メモリ周りの詳細仕様
poyo-vにおいては以下のようなメモリマップを想定しています。

|アドレス |容量 |内容 |対応する.hexファイル |
|--- |--- |--- |--- |
|0x00000-0x07FFF |32KiB |なし |software/${各プログラムのフォルダ名}/code.hex |
|0x08000-0x0FFFF |32KiB |.text(ROM) |software/${各プログラムのフォルダ名}/code.hex |
|0x10000-0x17FFF |32KiB |.rodata + .data + .bss + .comment(RAM) |software/${各プログラムのフォルダ名}/data{0, 1, 2, 3}.hex |
|0x18000-0x1FFFF |32KiB |stack(RAM) |なし |
|0x20010 |. |hardware counter用アドレス |なし |
|0x20020 |. |uart送信用アドレス |なし |
|0x20030 |. |uart受信用アドレス |なし |
|0x20040 |. |汎用入力ピン用アドレス |なし |
|0x20050 |. |汎用出力ピン用アドレス |なし |

また、poyo-vの読み込めるcode.hexファイル形式は、一行あたり4byteのデータ×16384行（合計64KiB）のテキストファイルです。一行あたり16進数で8文字が書かれており、一つの命令を表しています。たとえば、`0080006f`という行の場合は

|[3]番地 |[2]番地 |[1]番地 |[0]番地 |
|:---: |:---: |:---: |:---: |
|00 |80 |00 |6F |

というバイトオーダで命令メモリへ格納されることになります。

すなわち命令メモリの中身は、

|番地 |格納されたデータ |
|--- |--- |
|0 |code.hexの1行目{7,8}番目文字 |
|1 |code.hexの1行目{5,6}番目文字 |
|2 |code.hexの1行目{3,4}番目文字 |
|3 |code.hexの1行目{1,2}番目文字 |
|4 |code.hexの2行目{7,8}番目文字 |
|5 |code.hexの2行目{5,6}番目文字 |
|6 |code.hexの2行目{3,4}番目文字 |
|7 |code.hexの2行目{1,2}番目文字 |
|. |. |
|. |. |
|. |. |
|n |code.hexの {n/4+1} 行目 {7-2x,8-2x(x≡n(mod 4))} 番目文字 |

となります。

一方、data{0, 1, 2, 3}.hexは、一行あたり1byteのデータ×8192行（4ファイル合計で32KiB）のテキストファイルです。

|[3]番地 |[2]番地 |[1]番地 |[0]番地 |
|:---: |:---: |:---: |:---: |
|data3.hexに記述された値 |data2.hexに記述された値 |data1.hexに記述された値 |data0.hexに記述された値 |

というようにデータメモリへ格納されることになります。

すなわちデータメモリの中身は、

|番地 |格納されたデータ |
|--- |--- |
|0 |data0.hexの1行目 |
|1 |data1.hexの1行目 |
|2 |data2.hexの1行目 |
|3 |data3.hexの1行目 |
|4 |data0.hexの2行目 |
|5 |data1.hexの2行目 |
|6 |data2.hexの2行目 |
|7 |data3.hexの2行目 |
|. |. |
|. |. |
|. |. |
|n |data{x}.hex (x≡n(mod 4)) の {n/4+1} 行目 |

となります。poyo-vのデータメモリ（dmem.v）は実際には4つのインスタンスへと分割されて呼び出されており、それぞれのインスタンスが対応するファイルを読み込んでいます。
 
## Author
* **Ourfool in Saginomiya** -[homepage](http://www.saginomiya.xyz/)-

## License
This project is released under the MIT License - see the [LICENSE](LICENSE) file for details
