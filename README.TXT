■名称
　pdic-conv version 0.1.1 (2007-12-07版)

■これは何？
　「英辞郎 第三版」（アルク刊）同梱の辞書データを
　　・PDICバイナリ形式からPDIC１行テキスト形式 (pdic1line)
　　・「英辞郎ビューア」でも使える形式 (eview)
　に変換するスクリプトです。

　以下 <format> 部分を pdic1line または eview に読み替えて下さい。

■使用条件とか
　フリーウェアです。無保証です。

　CPANに載せるつもりで作りかけたライブラリを同梱しています。ライセンスはPerlライセンスにするつもりですが
　とりあえず二次配布は控えていただけると有難いです。

　※Encode::BOCU-1 というライブラリ（拙作）と合わせて使えば Unicode (BOCU-1) なPDIC辞書も読めるはずです。

■とりあえず必要なもの
　「英辞郎 第三版」（アルク刊）

　※英辞郎のテキストデータが欲しいだけならEDPで最新データをTEXT形式で売ってますのでそちらもご検討ください。
　http://www.eijiro.jp/
　その場合このツールは不要です。

■動作環境
　Mac OS X の「英辞郎 第三版」が動作するバージョンならたぶんOKです。OS X付属のPerlで行けます。
　※Windows その他の OS で使う場合は convert-all-***.sh の DICT_DIR を適宜書き換えて下さい。たぶん動きます。

■使い方
　（１）「英辞郎 第三版」のインストーラで英辞郎データをインストール
　　　　デスクトップに PDICViewer1024EE というフォルダができます。
　（２）このツールをどこか（ホームディレクトリ推奨）に展開し、convert-all-<format>.sh を走らせる。

　　% cd ~
　　% tar zxf pdic-conv-0.1.1.tar.gz
　　% cd pdic-conv
　　% ./convert-all-<format>.sh
　　[eijiro98]
　　[reiji98]
　　[ryaku98]
　　[waeiji98]
　　%

　（２）ちょっと時間がかかるので休憩。コーヒーをキーボードにこぼさないように。
　（３）~/pdic-conv/ に
　　　　　eijiro98.txt, reiji98.txt, ryaku98.txt, waeiji98.txt
　　　　というファイルができるので、後は煮るなり焼くなり・・・お好きなように。

■履歴
  version 0.1.1 上記２つをとりまとめ、あとotsuneさんの2007/5/9のパッチを適用
    < http://subtech.g.hatena.ne.jp/otsune/20070509/EIJIROPDICConverterDiff
　version 0.1 (2007-02-12版)
　version 0.1/e (2007-02-22 英辞郎ビューア対応版)

■作者
　naoya_t (aka. naochan)
　http://pdicviewer.naochan.com/
　http://d.hatena.ne.jp/NaoyaT/ (old)
  http://blog.livedoor.jp/naoya_t/ (new)
