/******************************************************
* MySQLのmy.cnfファイルに定義するようなデータベースの設定を行う
*******************************************************/

resource "aws_db_parameter_group" "example" {
  name   = "example"
  family = "mysql5.7"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

/*************************************
* データベースエンジンにオプション機能を追加
**************************************/

resource "aws_db_option_group" "example" {
  name                 = "example"
  engine_name          = "mysql"
  major_engine_version = "5.7"

  option {
    option_name = "MARIADB_AUDIT_PLUGIN" # https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/Appendix.MySQL.Options.html
  }
}

/**********************
* DBを稼働させるサブネット
***********************/

resource "aws_db_subnet_group" "example" {
  name       = "example"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id] # マルチAZなので複数設定
}

/**********************
* DBインスタンス用SG
***********************/

module "mysql_sg" {
  source      = "./security_group"
  name        = "mysql-sg"
  vpc_id      = aws_vpc.example.id
  port        = 3306
  cidr_blocks = [aws_vpc.example.cidr_block]
}

/**********************
* DBインスタンス
***********************/

resource "aws_db_instance" "example" {
  identifier                 = "example"
  engine                     = "mysql"
  engine_version             = "5.7.25"
  instance_class             = "db.t3.small"
  allocated_storage          = 20    # GiB
  max_allocated_storage      = 100   # 自動的にこの値までスケールする
  storage_type               = "gp2" # 汎用SSDの意
  storage_encrypted          = true
  kms_key_id                 = aws_kms_key.example.arn # kms_keyでディスク暗号化される。デフォルトのkms_keyだとアカウントを跨いだスナップショットの共有ができなくなる。ので自分で作ったやつが好ましい。
  username                   = "admin"
  password                   = "VeryStrongPassword!" # terraformの仕様上省略できない。平文での入力になってしまうのであとから変更する。一旦ダミー値をセット。
  multi_az                   = true
  publicly_accessible        = false # VPC外からのアクセスは禁止。
  backup_window              = "09:10-09:40" # バックアップのタイミング。UTCであることに注意。
  backup_retention_period    = 30 # バックアップを残しておく期間。最大35日間
  maintenance_window         = "mon:10:10-mon:10:40" # メンテナンス時間のタイミング。こちらもUTC。
  auto_minor_version_upgrade = false
  # deletion_protection        = true # 削除保護
  skip_final_snapshot        = true # インスタンス削除時にスナップショットを作成しないようにする。falseで作成するようになる。テストなのでtrueにしている。
  port                       = 3306
  apply_immediately          = false # 設定の変更を即時にする（＝ダウンタイムが発生する）か否か。falseの場合メンテナンス期間中に反映される。
  vpc_security_group_ids     = [module.mysql_sg.security_group_id]
  parameter_group_name       = aws_db_parameter_group.example.name
  option_group_name          = aws_db_option_group.example.name
  db_subnet_group_name       = aws_db_subnet_group.example.name

  lifecycle {
    ignore_changes = [password] # パスワードはterraformを介さずにあとから更新予定なので無視する。
  }
}