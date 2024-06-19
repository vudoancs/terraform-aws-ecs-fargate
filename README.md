
**VPC (Virtual Private Cloud)**
```
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "main-vpc"
  }
}

```
- Description: Creates a VPC with the specified CIDR block. The VPC is a virtual network dedicated to your AWS account, where you can launch AWS resources.
**Subnet**
```
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_block

  tags = {
    Name = "main-subnet"
  }
}

```
-Description: Creates a subnet within the specified VPC. A subnet is a range of IP addresses in your VPC.

**Security Group**
```
resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

```
- Description: Creates a security group for the ECS tasks. Security groups act as a virtual firewall for your instance to control inbound and outbound traffic.
  
**IAM Role for ECS Task Execution**
```
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}
```
- Description: Creates an IAM role that the ECS tasks can assume to interact with AWS services on your behalf.
  
**ECS Cluster**
```
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}
```
- Description: Creates an ECS cluster. An ECS cluster is a logical grouping of tasks or services

**ECS Task Definition**
```
resource "aws_ecs_task_definition" "main" {
  family                   = "ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "my-container"
    image     = "amazon/amazon-ecs-sample"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}
```
- Resource Type: aws_ecs_task_definition
- Resource Name: main
- Description: Defines the ECS task. It specifies the Docker image to use, the amount of CPU and memory to allocate, and port mappings. It also specifies that the task will run on Fargate

**ECS Service**
```
resource "aws_ecs_service" "main" {
  name            = "ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.main.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }
}
```
- Resource Type: aws_ecs_service
- Resource Name: main
- Description: Creates an ECS service that ensures a specified number of task definitions are running and reschedules tasks when a task fails. The service runs on Fargate and uses the VPC, subnet, and security group defined earlier.
