output "ecs_cluster_id" {
  values = aws_ecs_cluster.cluster.id
}
output "ecs_service_name" {
  value = aws_ecs_service.app.name
}
