# 60-ingress-alb/outputs.tf
output "frontend_target_group_arn" {
  value = aws_lb_target_group.frontend.arn
}