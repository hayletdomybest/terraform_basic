# // https://github.com/cn-terraform/terraform-aws-ecs-fargate-task-definition
# module "ecs-fargate-task-definition" {
#     source  = "cn-terraform/ecs-fargate-task-definition/aws"
#     version = "1.0.23"
#     name_prefix = local.prefix

#     container_name  = "HelloWorld"
#     container_image = "718286959245.dkr.ecr.ap-northeast-1.amazonaws.com/deploy-demo"
# }

resource "aws_ecs_task_definition" "hello_world_task_definition" {
    family = "${local.prefix}-task-definition"
    requires_compatibilities = ["FARGATE"]
    cpu                      = "1024"
    memory                   = "2048"
    network_mode             = "awsvpc"
    execution_role_arn       = aws_iam_role.task_execution_role.arn
    task_role_arn            = aws_iam_role.task_role.arn

    container_definitions    = jsonencode([
        {
            "name": "hello-world",
            "image": "718286959245.dkr.ecr.ap-northeast-1.amazonaws.com/deploy-demo:latest",      
            "memory": 512,
            "cpu":    256,
            "essential": true,
            "portMappings": [
                {
                    "containerPort": 80,
                    "hostPort":      80
                }
            ]
        },
        # {
        #     "name": "api",
        #     "image": "718286959245.dkr.ecr.ap-northeast-1.amazonaws.com/cms-api:latest",      
        #     "memory": 4096,
        #     "cpu":    2048,
        #     "essential": true,
        #     "portMappings": [
        #         {
        #             "containerPort": 80,
        #             "hostPort":      80
        #         }
        #     ]
        # }        
    ])

    depends_on = [
      aws_iam_role.task_role,
      aws_iam_role_policy_attachment.ecs_execution_policy_attachment
    ]
}

resource "aws_iam_role" "task_execution_role" {
  name = "${local.prefix}-task-execution-role"

  assume_role_policy = <<ROLEPOLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
ROLEPOLICY
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy_attachment" {
  role       = "${aws_iam_role.task_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

  depends_on = [
    aws_iam_role.task_execution_role
  ]
}

resource "aws_iam_role" "task_role" {
    name = "${local.prefix}-task-role"

    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "",
                "Action": "sts:AssumeRole"    
                "Effect": "Allow",
                "Principal": {
                    "Service": "ecs-tasks.amazonaws.com"
                },
            }
        ]
    })

    inline_policy {
        name = "${local.prefix}-task-role-policy"
        policy = jsonencode({
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": [
                        "s3:PutObject"
                    ],
                    "Effect": "Allow",
                    "Resource": "*"
                },
                {
                    "Action": [
                        "logs:CreateLogGroup",
                        "logs:CreateLogStream",
                        "logs:PutLogEvents",
                        "logs:DescribeLogGroups",
                    ],
                    "Effect": "Allow",
                    "Resource": "*"
                },
                {
                    "Action": [
                        "logs:CreateLogGroup",
                        "logs:CreateLogStream",
                        "logs:PutLogEvents",
                        "logs:DescribeLogGroups",
                    ],
                    "Effect": "Allow",
                    "Resource": "*"
                },                      
            ]
        })
    }
}
