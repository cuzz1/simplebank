## 前言

最近在公司有开始接触 Go 的项目，想系统的学习一下。相对来说 Go 的语法还是比较简单，很容易上手。快速看完两本入门书，想找一些偏项目的书来看，发现目前国内还是比较少。然后翻了一下培训机构的教程，感觉也不是很好，偶然在油管上看到这个教程 [Backend master class](https://www.youtube.com/watch?v=rx6CPDK_5mU)，感觉讲的不错，就把这个教程整理出来。

## 介绍

这是一个从设计、开发到部署的完整的 Go 项目，使用 PostgreSQL、Golang 和 Docker，这个项目主要来构建一个简单的银行系统，主要提供一下功能：

<!-- more -->

-   创建和管理帐户：所有者、余额、货币
-   记录所有余额变化：为每次更改创建一个帐户条目
-   转账交易：在一笔交易中，在两个账户之间进行一致的转账

## 数据库设计

### 设计数据库架构

使用 dbdiagram.io 设计表结构，采用的 DSL 语言来定义：

```dsl
Table accounts as A {
  id bigint [pk, increment, note: '主键']
  owner varchar [not null, note: '账户所有者'] 
  balance bigint [not null, note: '账户余额'] 
  currency varchar [not null, note: '货币类型，比如：人民币']
  created_at timestamptz [not null, default:`now()`, note: '创建时间']
  Indexes {
    owner
  }
  note: '账户'
}

Table entries {
  id bigint [pk, increment, note: '主键']
  account_id bigint [not null, ref: > A.id, note:'账户id，关联account的id']
  amount bigint [not null, note:'变化金额，可正可负']
  created_at timestamptz [not null, default:`now()`, note: '创建时间']
  Indexes {
    account_id
  }
  note: '记录所有余额变化'
}

Table transfers {
    id bigint [pk, increment, note: '主键']
    from_account_id bigint [not null, ref: > A.id, note: '转账id']
    to_account_id bigint [not null, ref: > A.id, note: '被转账id']
    amount bigint [not null, note: '必须为正']
    created_at timestamptz [not null, default:`now()`, note: '创建时间']
    Indexes {
      from_account_id
      to_account_id
      (from_account_id, to_account_id)
    }
    note: '转账交易记录'
}
```

可以生成响应的关系图：

<center><img src="http://img.cuzz.site/20201206135328.png" width="100%" /></center>

可以导出 PostgreSQL，MySQL等等

还可以创建分享链接，这个表的链接为： https://dbdiagram.io/d/5fcc5ee49a6c525a03b9f27d

### 使用 Docker 安装 Postgers

先安装 docker，可参考网上

先登入 [docker](https://hub.docker.com/) 官方，查找可用的镜像，找到一个为 `12-alpine`，使用 `docker pull <image>:<tag>` 方式拉去这个镜像

```
docker pull postgres:12-alpine
```

输入 `docker images` 就可看到我们拉去的镜像了

```
 ~ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
postgres            12-alpine           b5a8143fc58d        3 weeks ago         158MB
```

通过以下格式来运行，我们知道一个镜像（image）可用运行多个容器（container）

```
docker run --name<container_name>          // 容器名称
		   -e <environment_variable>       // 环境变量
		   -p <host_port:containter_ports> // 端口映射
		   -d <image>:<tag>                // 后台运行
```

运行镜像：

```
docker run --name postgres12 \
           -e POSTGRES_USER=root -e POSTGRES_PASSWORD=12356 \
		   -p 5432:5432 \
		   -d postgres:12-alpine \
```

使用 `docker ps` 查看运行的镜像

```
~ docker ps
CONTAINER ID        IMAGE                COMMAND                  CREATED              STATUS              PORTS                    NAMES
5c337d6516a6        postgres:12-alpine   "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:5432->5432/tcp   postgres12
```

在运行的容器中执行命令：

```
docker exec -it <container_name_or_id> <commend> [args]
```

进入 postgres 命令终端

```
docker exec -it postgres12 psql -U root
psql (12.5)
Type "help" for help.

root=#
```

使用 DataGrip 连接数据库，并且把生成的 SQL 导入 DataGrip 中，生成相应的表。

## SQL/GORM/SQLX/SQLC生成CRUD的比较

SQL

-   快、直接
-   手动映射 
-   容易写错

GORM

-   CRUD 已经实现了
-   需要学习一些 gorm 语法
-   比较慢

SQLX

-   快，容易使用
-   通过查询语句和结构体tag映射

SQLC

-   快，容易使用
-   自动代码生成

最终我们选择 SQLC，https://github.com/kyleconroy/sqlc

在 mac 上安装

```
brew install kyleconroy/sqlc/sqlc
```

