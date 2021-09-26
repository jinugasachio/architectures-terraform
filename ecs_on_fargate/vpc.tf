/**********************************
* VPCの設定
**********************************/

resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true # DNSサーバーによる名前解決を有効。
  enable_dns_hostnames = true # パブリックDNSホスト名を自動的に割り当てる

  tags = {
    Name = "example"
  }
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

/**********************************
* パブリックサブネットの設定（マルチAZ）
**********************************/

resource "aws_subnet" "public_0" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # このサブネットで起動したインスタンスにパブリックIPアドレスを自動的に割り当てる。
  availability_zone       = "ap-northeast-1a"
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id
}

# VPC内の通信を有効にするlocalルートは自動で生成される。
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.example.id
  destination_cidr_block = "0.0.0.0/0"
}

# 関連づけを忘れるとデフォルトルートテーブルが使われる。アンチパターンなので、関連付けは忘れないように。
resource "aws_route_table_association" "public_0" {
  subnet_id      = aws_subnet.public_0.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

/**********************************
* プライベートサブネットの設定（マルチAZ）
**********************************/

resource "aws_subnet" "private_0" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.65.0/24"
  map_public_ip_on_launch = false # プライベートなので。
  availability_zone       = "ap-northeast-1a"
}

resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.66.0/24"
  map_public_ip_on_launch = false # プライベートなので。
  availability_zone       = "ap-northeast-1c"
}

resource "aws_route_table" "private_0" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route" "private_0" {
  route_table_id         = aws_route_table.private_0.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway_0.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_1" {
  route_table_id         = aws_route_table.private_1.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway_1.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_0" {
  subnet_id      = aws_subnet.private_0.id
  route_table_id = aws_route_table.private_0.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

/**********************************
* NATゲートウェイの設定（マルチAZ）
**********************************/

resource "aws_eip" "nat_gateway_0" {
  vpc        = true                           # VPC内にあるか否かのフラグ
  depends_on = [aws_internet_gateway.example] # IGに依存しているので明示的に依存関係を記すことで先にIG → EIP と言う順序で構築されるようになる。
}

resource "aws_eip" "nat_gateway_1" {
  vpc        = true
  depends_on = [aws_internet_gateway.example]
}

resource "aws_nat_gateway" "nat_gateway_0" {
  allocation_id = aws_eip.nat_gateway_0.id # 割り当てられるEIPを設定
  subnet_id     = aws_subnet.public_0.id
  depends_on    = [aws_internet_gateway.example] # aws_eipと同じ
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_gateway_1.id
  subnet_id     = aws_subnet.public_1.id
  depends_on    = [aws_internet_gateway.example]
}
