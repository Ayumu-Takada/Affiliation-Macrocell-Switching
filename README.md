# name

Ayumu Takada

## Overview

分散アンテナ型セルシステムにおけるアップリンクのピコセル帰属切り替えの検討

## Features

###フォルダ構成###
インコード：single_3user_choosebetter_d50.m(1)
関数コード：add_TDL_A_fading.m, add_TDL_D_fading.m(2-1), create_bs_coordinate.m, create_user_coordinate.m(2-2), Antenna_select.m(2-3), calculate_estimated_throughput_single_PF.m(2-4), calculate_throughput_single_PF.m(2-5),
 TimeIndicator.m(2-6)
グラフプロット：Figure_plot(3)    


## Usage
###シミュレーションプログラムの使い方###

(1) はメインファイルであり，(2-1)～(2-6)までは(2)で用いる関数ファイルになっている．変更する変数は以下．

　   num_users :1マクロセル当たりのユーザ数
     distance  :アンテナ間距離
     f_c       :中心周波数
     
　 ファイル名 single_〇user_choosebetter_d△.mにおいて，〇はnum_users,△はdistanceを表す. 従来法においては，コード内のピコセルの切り替え個数p=0とすることでシミュレーションできる．
　 実行すると様々なデータがmatファイルに保存されるようになっている．またそのファイルは

　   提案法 result/proposed_choosebetter_4.65GHz/〇user/result_d△_rng...(0～499).mat (f_c = 4.65GHz)
            result/proposed_choosebetter_28GHz/〇user/result_d△_rng...(0～499).mat (f_c = 28GHz)
     従来法 result/conventional/〇user/result_d△_rng...(0～499).mat

   として保存する．ここで...は試行回数(500回)．
　
　 (2-1)レイリー，ライシアンのフェージングの周波数を求めることができる．
　 (2-2)六角セルの配置，マクロセル内のユーザーの配置を決定できる．
　 (2-3)すべてのピコセルに対して自分が帰属しているマクロセルの番号が振られる．
　 　　 あるマクロセル内に隣接する12個のピコセルを選択できる．
   (2-4)全マクロセルのユーザー(1つ前のサブフレームで決定)を利用して，当該マクロセルのユーザーのスループットが計算される．
   (2-5)全マクロセルのユーザー(同じサブフレームで決定)を利用して，当該マクロセルのユーザーのスループットが計算される．
   (2-6)実行の進捗状況が表示される．


(3) シミュレーション結果を用いて図を作成する．用いたファイルは
      Figure_distanace.m       (4-1)
      Figure_distance_axis.m   (4-2)
      Figure_user.m            (4-3)
      Figure_numcellchange.m   (4-4)
    loadの後のmatファイルの部分を適宜変更して実行する．

　  (4-1) ユーザ数は固定する．従来法と提案法で各distanceに対して横軸FI, 縦軸Throughputでプロットするコード．
　  (4-2) ユーザ数は固定する．従来法と提案法で横軸 Distance, 縦軸 Throughputでプロットするコード．
　  (4-3) アンテナ間距離は固定する．提案法において，横軸がユーザ数，縦軸が全マクロセルにおけるピコセルの平均帰属切り替え数をプロットするコード．
  　(4-4) アンテナ間距離は固定する．従来法と提案法で各ユーザ数に対して(計8個)横軸 FI, 縦軸Throughputでプロットする．



## My Research Publication

[URL](https://ieeexplore.ieee.org/document/10767918)
