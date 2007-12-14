■名称
　pdic-conv version 0.2 (2007-12-14版)

■これは何？
  PDIC形式の辞書を
　　・１行テキスト形式 (pdic-to-1line.pl)
　　・[NEW!] Mac OS X Leopardの「辞書」形式 (pdic-to-leopard.pl)
　に変換するスクリプトです。

　「英辞郎 第三版」（アルク刊）同梱の辞書データを
　　・PDICバイナリ形式からPDIC１行テキスト形式
　　・「英辞郎ビューア」でも使える形式
　に変換するスクリプトも付属しています。
　詳しくは README.eijiro3 をどうぞ。

　Leopard形式への変換は「とりあえず」です。
　発音記号や他のエントリーへのリンクなどの情報はまだ入っていません。
　（発音記号はSIL-IPAコードからUTF-8に変換する必要あり。C++のライブラリあるので近々移植します）

■使用条件とか
　フリーウェアです。無保証です。
　CPANに載せるつもりで作りかけたライブラリを同梱しています。ライセンスはPerlライセンスで。

■とりあえず必要なもの
　変換したいPDIC形式の辞書。
　Leopardの「辞書」形式に変換する場合は、Leopardのインストールディスクに含まれる開発ツールを先にインストールする必要があります。

■動作環境
　Mac OS X 10.5.1以降を推奨

■使い方

　　% perl pdic-to-1line.pl PDIC辞書 sjis  →Shift_JISで保存。(Ver.4辞書のみ)
　　% perl pdic-to-1line.pl PDIC辞書       →UTF-8で保存。(Unicode辞書はこちら)

　　% perl pdic-to-leopard.pl PDIC辞書
　　% perl pdic-to-leopard.pl PDIC辞書 フォントファミリー名  →見出し語の表示フォント(CSS用)

■注意事項

　アルク刊「英辞郎　第三版」に同梱されているPDIC辞書も一応変換できますが、GB単位になるので
　ディスク容量にかなりのゆとりが必要です。時間もそれなりに（十数分？数十分？）かかります。
　そのうちこのツール自体がバージョンアップするので、試すのはそれからにしても遅くはありません。

　なお、テキスト形式の英辞郎をLeopard形式に変換するには、このツールではなく
　　http://www.binword.com/blog/archives/000569.html
　の記事が参考になるかと思います。

■履歴
  version 0.2 Leopardの辞書形式に対応
  version 0.1.1 上記２つをとりまとめ、あとotsuneさんの2007/5/9のパッチを適用
    < http://subtech.g.hatena.ne.jp/otsune/20070509/EIJIROPDICConverterDiff
　version 0.1 (2007-02-12版)
　version 0.1/e (2007-02-22 英辞郎ビューア対応版)

■作者
　naoya_t (aka. naochan)
　http://pdicviewer.naochan.com/
　http://d.hatena.ne.jp/NaoyaT/ (old)
  http://blog.livedoor.jp/naoya_t/ (new)
