## Docekrのお作法メモ  

レジストリは、コンテナイメージやリポジトリを格納・管理するところ（Docker Hub、AWS ECRなど）。   
リポジトリは、名前は同じだがタグが異なるイメージの集合。Gihubのリポジトリとタグをイメージするとわかりやすい。   

#### 起動中のコンテナを確認する   
```
sudo docker ps -a
```

#### 停止中のコンテナを確認する  
```
sudo docker ps
```

#### 起動中のイメージを確認する  
```
sudo docker images
```

#### コンテナを削除する  
```
sudo docker rm <コンテナID>
```

#### イメージを削除する  
```
sudo docker rmi <イメージID>
```

#### 起動  
```
sudo docker run --name <image name> -it <IMAGE ID>
```

#### 再起動  
```
sudo docker attach <CONTAINER>
```

#### dockerイメージを保存  
```
docker save <コンテナイメージID> > <書き出すイメージのファイル名>.tar
```

#### dockerイメージをロード  
```
docker load < <読み込むイメージのファイル名>.tar
```

#### docker commitでコンテナをイメージに変換  
```
docker commit <YOUR_CONTAINER_ID> <NAME>
```
