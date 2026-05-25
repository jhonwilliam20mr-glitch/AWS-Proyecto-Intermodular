# Instancia Pública (Nginx, Gitea, VSCode)
resource "aws_instance" "public_node" {
  ami                    = "ami-091138d0f0d41ff90"
  instance_type          = "t3.micro" 
  subnet_id              = aws_subnet.public.id
  user_data              = file("scripts/setup_public.sh")
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  key_name               = "vockey"
}

# Instancia Privada 1 (Base de Datos Postgres Principal)
resource "aws_instance" "private_node_1" {
  ami                    = "ami-091138d0f0d41ff90"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  private_ip             = "10.0.2.100"
  user_data              = file("scripts/setup_private.sh")
  vpc_security_group_ids = [aws_security_group.allow_internal.id]
  key_name               = "vockey"
}

# Instancia Privada 2 (Nextcloud Nodo 1 - Se conecta a la BD de la Instancia 1)
resource "aws_instance" "private_node_2" {
  ami                    = "ami-091138d0f0d41ff90"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  private_ip             = "10.0.2.110"
  user_data              = file("scripts/setup_private_2.sh")
  vpc_security_group_ids = [aws_security_group.allow_internal.id]
  key_name               = "vockey"
}
# Instancia Privada 2 (Nextcloud Nodo 2 - Se conecta a la BD de la Instancia 1)
resource "aws_instance" "private_node_3" {
  ami                    = "ami-091138d0f0d41ff90"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  private_ip             = "10.0.2.120"
  user_data              = file("scripts/setup_private_3.sh")
  vpc_security_group_ids = [aws_security_group.allow_internal.id]
  key_name               = "vockey"
}
