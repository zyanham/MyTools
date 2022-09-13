### Dockerインストール(Ubuntu 20.04)  
Dockerをインストールする手順はだいたいこんな感じ。

```bash  
# インストール  
sudo apt-get install docker docker.io  
  
# インストール後にUbuntuのグループでdockerが追加されているか確認する  
getent group docker  
  
# dockerグループが存在しない場合は下記  
sudo goutpadd docker  
  
# 下記コマンドでユーザーを追加する  
sudo gpasswd -a <ユーザー名> docker  
  
# 下記コマンドで確認  
id <ユーザー名>  
```

### Dockerビルド  
Dockerによるイメージを１から作るときはDockerfileと呼ばれるファイルを作成し、  
ビルド情報を記載して、ビルドコマンドを実施すると作成が可能になる。  
  
```bash
# カレントディレクトリにDockerfileがある場合は下記コマンド  
docker build .  
  
ビルドしたDockerイメージをコンテナにして実行するには下記コマンド  
docker run --name [イメージ名] -it [イメージID]  
```
  
### Dockerのお作法メモ  
レジストリは、コンテナイメージやリポジトリを格納・管理するところ（Docker Hub、AWS ECRなど）。   
リポジトリは、名前は同じだがタグが異なるイメージの集合。Gihubのリポジトリとタグをイメージするとわかりやすい。   

```bash
# 起動中のコンテナを確認する
sudo docker ps -a

# 全コンテナを確認する  
sudo docker ps

# 起動中のイメージを確認する  
sudo docker images

# コンテナを削除する  
sudo docker rm <コンテナID>

# イメージを削除する  
sudo docker rmi <イメージID>  
  
# イメージをコンテナにして実行  
sudo docker run --name <image name> -it <IMAGE ID>  
  
# Dockerコンテナの停止は  
docker stop <コンテナ名>  
  
# 停止したDockerコンテナの起動は  
dokcer start <コンテナ名>  
  
# Dockerコンテナの再起動は  
docker restart <コンテナ名>  
  
# 起動したDockerコンテナにログインするには  
docker exec -it [コンテナ名] /bin/bash  
  
# root以外でログインしたい時は  
docker exec -it [コンテナ名] --user [ユーザー名または UID] /bin/bash  
  
# dockerイメージを保存  
docker save <コンテナイメージID> > <書き出すイメージのファイル名>.tar

# dockerイメージをロード  
docker load < <読み込むイメージのファイル名>.tar

# docker commitでコンテナをイメージに変換  
docker commit <YOUR_CONTAINER_ID> <NAME>
```

### Dockerのネットワーク事情  
Dockerをインストールしたすべての環境にはdocker0というブリッジネットワークが作られる。  
(オプションでネットワーク名も指定可能とのこと)  
  
```bash
# dockerのネットワークを確認するコマンド  
sudo docker network ls  
```
