[PostgreSQL Official](https://www.postgresql.org/)  
[PostgreSQL Download](https://www.postgresql.org/download/)  
[PostgreSQL Ubuntu Install](https://www.postgresql.org/download/linux/ubuntu/)  
  
PostgreSQLをインストール時にpostgresという管理ユーザーが追加される。  
※管理ユーザーは何でもできてしまうので注意

Ubuntuで管理ユーザーpostgresにユーザーを切り替えたい
```
sudo -u postgres -i
```

createdb <dbname>  
