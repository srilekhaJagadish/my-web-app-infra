# --- EC2 Launch Template ---
resource "aws_launch_template" "spring_boot_lt" {
  name_prefix   = "fomax-node-"
  image_id      = "ami-0cff7528ff583bf9a" # Amazon Linux 2023
  instance_type = "t3.medium"

  network_interfaces {
    security_groups = [aws_security_group.ec2_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y amazon-efs-utils java-17-amazon-corretto

              # Mount EFS
              mkdir -p /mnt/efs/staging
              mount -t efs -o tls ${aws_efs_file_system.staging.id}:/ /mnt/efs/staging

              # Bootstrap Spring Boot (example)
              # aws s3 cp s3://my-bucket/app.jar /opt/app.jar
              # java -jar /opt/app.jar
              EOF
  )
}

# --- Auto Scaling Group with Target Tracking ---
resource "aws_autoscaling_group" "app_asg" {
  vpc_zone_identifier = module.vpc.private_subnets
  target_group_arns   = [aws_lb_target_group.app_tg.arn]
  min_size            = 2
  max_size            = 20
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.spring_boot_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "target_tracking_cpu" {
  name                   = "cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0 # Scales out when CPU hits 60%
  }
}