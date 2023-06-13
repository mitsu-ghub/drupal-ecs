

# Create ECS cluster
resource "aws_ecs_cluster" "drupal_cluster" {
  name = "drupal-cluster"  # Replace with your desired cluster name
}

# Create ECS task definition
resource "aws_ecs_task_definition" "drupal_task_definition" {
  family                = "drupal-task"  # Replace with your desired task family name
  container_definitions = <<DEFINITION
[
  {
    "name": "drupal",
    "image": "drupal:latest",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "environment": [
      {
        "name": "MYSQL_DATABASE",
        "value": "drupal"
      },
      {
        "name": "MYSQL_USER",
        "value": "admin"
      },
      {
        "name": "MYSQL_PASSWORD",
        "value": "password"
      },
      {
        "name": "MYSQL_HOST",
        "value": "${aws_rds_cluster.drupal_db_cluster.endpoint}"
      }
    ]
  }
]
DEFINITION

  requires_compatibilities = ["EC2"]
  network_mode            = "awsvpc"
  cpu                     = "512"
  memory                  = "1024"
  depends_on = [ module.vpc, aws_rds_cluster.drupal_db_cluster ]
}

# Create ECS service
resource "aws_ecs_service" "drupal_service" {
  name            = "drupal-service"  # Replace with your desired service name
  cluster         = aws_ecs_cluster.drupal_cluster.id
  task_definition = aws_ecs_task_definition.drupal_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = module.vpc.private_subnets  # Replace with your desired subnets
    security_groups = [aws_security_group.drupal_sg.id]  # Replace with your desired security groups
  }

 load_balancer {
    target_group_arn = aws_lb_target_group.drupal_target_group.arn  # Replace with your actual target group ARN
    container_name   = "drupal"
    container_port   = 80
  }
}


# Create ECS service autoscaling target
resource "aws_appautoscaling_target" "drupal_autoscaling_target" {
  max_capacity       = 4  # Replace with your desired maximum number of instances
  min_capacity       = 1  # Replace with your desired minimum number of instances
  resource_id        = "service/${aws_ecs_cluster.drupal_cluster.id}/${aws_ecs_service.drupal_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Create ECS service autoscaling policy
resource "aws_appautoscaling_policy" "drupal_autoscaling_policy" {
  name               = "drupal-autoscaling-policy"  # Replace with your desired policy name
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.drupal_autoscaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.drupal_autoscaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.drupal_autoscaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_out_cooldown     = 60  # Replace with your desired cooldown period
    scale_in_cooldown      = 60  # Replace with your desired cooldown period
    target_value           = 50  # Replace with your desired target CPU utilization percentage
  }
}